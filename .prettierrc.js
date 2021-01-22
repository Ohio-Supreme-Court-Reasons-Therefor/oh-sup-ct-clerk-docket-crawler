/**
 * .prettier.js 
 * 
 * This is a "prettier" configuration file per https://prettier.io/docs/en/configuration.html
 * 
 * The options configured in this file are described at https://prettier.io/docs/en/options.html
 * 
 * Why ".prettier.js" instead of, for example, ".prettier.json"? Because comments!
 */
 module.exports = {
    "printWidth": 130,       // Default: 80, but seriously, most people have monitors that can handle widths greater than 80
    "tabWidth": 4,           // Default: 2, but it's easier to see levels with 4.
    "useTabs": false,
    "singleQuote": true,     // Default: false
    "quoteProps": "preserve",// Default: "as-needed"
    "jsxSingleQuote": true,  // Default: false
    "endOfLine": "lf",       // Default: "auto"
    // Configuration overrides; see https://prettier.io/docs/en/configuration.html
    "overrides": []
};



