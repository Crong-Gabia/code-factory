/* eslint-env node */

module.exports = {
  root: true,
  env: { node: true, es2022: true, jest: true },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: "module",
    project: "./tsconfig.json",
  },
  plugins: ["@typescript-eslint"],
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended-type-checked",
    "plugin:@typescript-eslint/stylistic-type-checked",
    "prettier",
  ],
  rules: {
    semi: ["error", "always"],
    quotes: ["error", "double"],
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": [
      "error",
      { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
    ],
    "@typescript-eslint/naming-convention": [
      "error",
      { selector: "default", format: ["camelCase"] },
      { selector: "property", format: ["snake_case", "camelCase"] },
      { selector: "variable", format: ["snake_case", "camelCase"] },
      { selector: "parameter", format: ["snake_case", "camelCase"], leadingUnderscore: "allow" },
      {
        selector: "memberLike",
        modifiers: ["private"],
        format: ["snake_case"],
        leadingUnderscore: "require",
      },
      { selector: "typeLike", format: ["PascalCase"] },
    ],
    "@typescript-eslint/no-misused-promises": [
      "error",
      { checksVoidReturn: { attributes: false } },
    ],
  },
  ignorePatterns: ["dist/"],
};
