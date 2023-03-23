const { environment } = require("@rails/webpacker");

module.exports = environment;

// https://stackoverflow.com/questions/69394632/webpack-build-failing-with-err-ossl-evp-unsupported/69691525#69691525
const crypto = require("crypto");
const crypto_orig_createHash = crypto.createHash;
crypto.createHash = (algorithm) =>
  crypto_orig_createHash(algorithm == "md4" ? "sha256" : algorithm);

const webpack = require("webpack");
environment.plugins.append(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    Popper: ["popper.js", "default"],
  })
);
