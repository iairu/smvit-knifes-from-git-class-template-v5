// docusaurus.config.ts
import { themes as prismThemes } from "prism-react-renderer";
import type { Config } from "@docusaurus/types";
import type * as Preset from "@docusaurus/preset-classic";
import CssMinimizerPlugin from "css-minimizer-webpack-plugin";

// Build strictness (UAT defaults to warn; set DOCS_STRICT=1 in PROD to fail on broken links)
const strictMode = process.env.DOCS_STRICT === "1";
const brokenPolicy = strictMode ? "throw" : "warn";

// Build metadata from environment (provided by Makefile / CI)
const buildDate = process.env.BUILD_DATE || "20251012-2333";
const appVersion = process.env.APP_VERSION || "20251012-2333";

const config: Config = {
  title: "KNIFE Preview - Knowledge in Friendly Examples", // ✅ povinné
  tagline: "Context Aware Approach",
  url: process.env.SITE_URL || "https://knifes.systemthinking.sk", // can be overridden in CI/local
  baseUrl: process.env.BASE_URL || "/", // can be overridden in CI/local
  trailingSlash: false,
  favicon: "img/favicon.ico",

  organizationName: "KNIFE-Framework",
  projectName: "knifes_overview",
  deploymentBranch: "gh-pages-docusaurus",

  onBrokenLinks: brokenPolicy,
  onBrokenAnchors: brokenPolicy,
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: brokenPolicy,
    },
  },
  future: { v4: true },

  i18n: {
    defaultLocale: "sk",
    locales: ["sk", "en"],
    localeConfigs: {
      sk: { label: "Slovenčina", htmlLang: "sk" },
      en: { label: "English", htmlLang: "en" },
    },
  },

  presets: [
    [
      "classic",
      {
        docs: {
          path: "docs",
          routeBasePath: "/", // docs ako homepage
          tags: false, // disable docs tag routes (avoids missing tags file + duplicate /tags warnings)
          numberPrefixParser: false,
          editCurrentVersion: false,
          editUrl: undefined,
          exclude: [
            "**/README.migrated.md",
            "**/README_.md",
            "**/_legacy/**",
            "**/templates/**",
            "**/_templates/**",
            "**/*.template.md",
            "**/*index.template.md",
          ],
          sidebarPath: require.resolve("./sidebars.ts"),
        },
        blog: false,
        theme: { customCss: require.resolve("./src/css/custom.css") },
        // Avoid duplicate /tags route warnings by pointing sitemap ignorePatterns to the custom docs tags path and (defensively) blog tag routes
        sitemap: {
          changefreq: "weekly",
          priority: 0.5,
          ignorePatterns: [
            "/docs-tags/**",
            "/blog/tags/**",
            "/blog/**/tags/**",
          ],
          filename: "sitemap.xml",
        },
      } satisfies Preset.Options,
    ],
  ],

  plugins: [
    [
      "@docusaurus/plugin-google-gtag",
      { trackingID: "G-LV31TWZZK6", anonymizeIP: true },
    ],
    [
      "@docusaurus/plugin-client-redirects",
      {
        redirects: [
          // Root & locale root fixes
          { from: "/", to: "/sk" },
          // { from: "/en/index", to: "/en" },
          // { from: "/sk/index", to: "/sk" },

          // Backward-compatible old paths
          { from: ["/index", "/home"], to: "/sk" },
          // { from: ["/knifes", "/sk/knifes"], to: "/sk/knifes/overview" },
          // { from: ['/7Ds'],                 to: '/sk/7Ds' },
        ],
        createRedirects(existingPath) {
          // normalize trailing slash variants
          if (existingPath !== "/" && existingPath.endsWith("/")) {
            return [existingPath.slice(0, -1)];
          }
          if (existingPath === "/en/") {
            return ["/en"];
          }
          return [];
        },
      },
    ],
    function cssMinimizerWorkaround() {
      return {
        name: "css-minimizer-parallel-false",
        configureWebpack() {
          return {
            optimization: {
              minimizer: [
                new CssMinimizerPlugin({
                  parallel: false,
                  // Use CSO instead of cssnano to avoid "Unexpected '/'" parse errors
                  minify: CssMinimizerPlugin.cssoMinify,
                  minimizerOptions: {
                    restructure: false,
                  },
                }),
              ],
            },
          };
        },
      };
    },
  ],

  themeConfig: {
    image: "https://iairu.com/_global/logo.svg",
    navbar: {
      title: "SMVIT KNIFE Framework",
      logo: {
        alt: "KNIFE Logo",
        src: "https://iairu.com/_global/logo.svg",
        href: "/sk",
      },
      items: [
        { to: "/sk", label: "HOME", position: "left" },
        { to: "/sk/knifes", label: "KNIFES", position: "left" },
        { to: "/sk/7ds/", label: "7DS", position: "left" },
        {
          to: "/sk/student/deliverables/ondrej",
          label: "STUDENT - Ondrej",
          position: "left",
        },
        // { to: '/sk/7Ds', label: '7Ds', position: 'left' },
        {
          href: "https://github.com/KNIFE-Framework/knifes_overview",
          label: "GitHub",
          position: "right",
        },
      ],
    },
    footer: {
      style: "dark",
      links: [],
      copyright: `© ${new Date().getFullYear()} Context Aware Solutions. Version: ${appVersion} • Last build: ${buildDate} • Built with Docusaurus.`,
    },
    prism: { theme: prismThemes.github, darkTheme: prismThemes.dracula },
    docs: { sidebar: { hideable: true, autoCollapseCategories: true } },
  } satisfies Preset.ThemeConfig,

  // Ak si kdekoľvek mal vlastné polia (napr. writeJsonindex.md), daj ich sem:
  // customFields: { writeJsonIndex: true },
};

export default config;
