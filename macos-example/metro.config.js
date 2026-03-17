const path = require('path');
const { getDefaultConfig } = require('@react-native/metro-config');

// Monorepo root — so Metro can see the library source in root/src/
const root = path.resolve(__dirname, '..');

// react-native-macos lives in macos-example/node_modules (not hoisted to root)
const rnMacosDir = path.dirname(
  require.resolve('react-native-macos/package.json', { paths: [__dirname] })
);

// Pin react to macos-example/node_modules to guarantee a single instance.
// With nmHoistingLimits:workspaces, react might be found in multiple locations
// across the monorepo, causing the "Cannot read property 'useRef' of null"
// dispatcher mismatch error.
const reactMainPath = require.resolve('react', { paths: [__dirname] });

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 *
 * @type {import('metro-config').MetroConfig}
 */
const config = getDefaultConfig(__dirname);

// Keep macos-example as the projectRoot so that macos-example/node_modules is
// always under the project root and fully watched by Metro.
config.projectRoot = __dirname;

// Watch the monorepo root so the library source (root/src/) is visible.
config.watchFolders = [root];

config.resolver = {
  ...config.resolver,
  // Register 'macos' so Metro resolves .macos.* extension files.
  platforms: [...(config.resolver.platforms || []), 'macos'],
  // When resolving from any file in the monorepo, also look in
  // macos-example/node_modules so all workspace packages are found.
  nodeModulesPaths: [path.join(__dirname, 'node_modules')],
};

// Redirect ALL react-native imports → react-native-macos using module-name
// redirects (NOT raw file paths). This lets Metro handle extension resolution,
// platform variants (.macos.js etc.), and file indexing correctly.
//
//   'react-native'              → 'react-native-macos'  (resolved via nodeModulesPaths)
//   'react-native/Libraries/…'  → relative from react-native-macos root
//
// The fakeOrigin trick makes relative resolution start from within the
// react-native-macos package, so Metro finds the right file and indexes it.
const fakeOrigin = path.join(rnMacosDir, '_resolver_shim.js');

config.resolver.resolveRequest = (context, moduleName, platform) => {
  // Pin react to a single instance — prevents the "useRef of null" dispatcher
  // mismatch that occurs when multiple React instances exist in the monorepo.
  if (moduleName === 'react') {
    return { filePath: reactMainPath, type: 'sourceFile' };
  }

  if (moduleName === 'react-native') {
    return context.resolveRequest(context, 'react-native-macos', platform);
  }

  if (moduleName.startsWith('react-native/')) {
    // For deep subpath imports, resolve relative to react-native-macos root
    // so Metro uses its full resolution (extensions, platform variants, etc.)
    const subPath = './' + moduleName.slice('react-native/'.length);
    return context.resolveRequest(
      { ...context, originModulePath: fakeOrigin },
      subPath,
      platform
    );
  }

  return context.resolveRequest(context, moduleName, platform);
};

module.exports = config;
