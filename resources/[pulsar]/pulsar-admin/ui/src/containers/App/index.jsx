import "@babel/polyfill";

import React from "react";
import { useSelector } from "react-redux";
import CssBaseline from "@material-ui/core/CssBaseline";
import {
  ThemeProvider,
  createTheme,
  StyledEngineProvider,
} from "@material-ui/core";
import { library } from "@fortawesome/fontawesome-svg-core";
import { fas } from "@fortawesome/free-solid-svg-icons";
import { far } from "@fortawesome/free-regular-svg-icons";
import { fab } from "@fortawesome/free-brands-svg-icons";
import { HashRouter } from "react-router-dom";

import "react-image-lightbox/style.css";

import Panel from "../Panel";

library.add(fab, fas, far);

export default () => {
  const muiTheme = createTheme({
    typography: {
      fontFamily: ["Exo"],
      fontWeightRegular: 400,
    },
    palette: {
      primary: {
        main: "#7C3AED",
        light: "#A78BFA",
        dark: "#5B21B6",
        contrastText: "#ffffff",
      },
      secondary: {
        main: "#0C0C1A",
        light: "#111124",
        dark: "#080812",
        contrastText: "#ffffff",
      },
      error: {
        main: "#DC2626",
        light: "#EF4444",
        dark: "#991B1B",
      },
      success: {
        main: "#059669",
        light: "#10B981",
        dark: "#065F46",
      },
      warning: {
        main: "#D97706",
        light: "#F59E0B",
        dark: "#92400E",
      },
      info: {
        main: "#2563EB",
        light: "#3B82F6",
        dark: "#1D4ED8",
      },
      text: {
        main: "#E2E8F0",
        alt: "#94A3B8",
        info: "#64748B",
        light: "#F8FAFC",
        dark: "#000000",
      },
      border: {
        main: "#1A1A2E",
        light: "#ffffff",
        dark: "#1A1A2E",
        input: "rgba(124, 58, 237, 0.35)",
        divider: "#1A1A2E",
      },
      mode: "dark",
    },
    components: {
      MuiTooltip: {
        styleOverrides: {
          tooltip: {
            fontSize: 13,
            backgroundColor: "#0C0C1A",
            border: "1px solid #1A1A2E",
            borderRadius: 4,
          },
        },
      },
      MuiPaper: {
        styleOverrides: {
          root: {
            background: "#0C0C1A",
          },
        },
      },
      MuiButton: {
        styleOverrides: {
          root: {
            borderRadius: 4,
            textTransform: "none",
            letterSpacing: "0.02em",
            fontWeight: 500,
            boxShadow: "none",
            "&:hover": { boxShadow: "none" },
          },
        },
      },
      MuiOutlinedInput: {
        styleOverrides: {
          root: {
            borderRadius: 4,
            "& fieldset": { borderColor: "#1A1A2E" },
            "&:hover fieldset": { borderColor: "rgba(124, 58, 237, 0.5)" },
            "&.Mui-focused fieldset": { borderColor: "#7C3AED" },
          },
        },
      },
      MuiAutocomplete: {
        styleOverrides: {
          paper: {
            boxShadow: "0 8px 30px rgba(0,0,0,0.7)",
            border: "1px solid #1A1A2E",
          },
        },
      },
      MuiBackdrop: {
        styleOverrides: {
          root: {
            height: "90%",
            width: "85%",
            margin: "auto",
          },
        },
      },
      MuiChip: {
        styleOverrides: {
          root: {
            borderRadius: 4,
            fontSize: 11,
            height: 22,
            fontWeight: 600,
            letterSpacing: "0.04em",
          },
        },
      },
      MuiLinearProgress: {
        styleOverrides: {
          root: {
            borderRadius: 2,
            height: 5,
            backgroundColor: "#1A1A2E",
          },
          bar: {
            borderRadius: 2,
          },
        },
      },
      MuiDivider: {
        styleOverrides: {
          root: {
            borderColor: "#1A1A2E",
          },
        },
      },
      MuiListItem: {
        styleOverrides: {
          root: {
            borderRadius: 0,
          },
        },
      },
      MuiCssBaseline: {
        styleOverrides: {
          ".Toastify__toast-container--bottom-right": {
            bottom: "0.5em !important",
            right: "0.5em !important",
            position: "absolute !important",
          },
          ".Toastify__toast": {
            background: "#0C0C1A !important",
            border: "1px solid #1A1A2E !important",
            borderRadius: "4px !important",
            color: "#E2E8F0 !important",
            fontSize: "14px !important",
          },
          ".Toastify__progress-bar": {
            background: "#7C3AED !important",
          },
          "*": {
            "&::-webkit-scrollbar": {
              width: 5,
            },
            "&::-webkit-scrollbar-thumb": {
              background: "#1A1A3E",
              borderRadius: 3,
              transition: "background ease-in 0.15s",
            },
            "&::-webkit-scrollbar-thumb:hover": {
              background: "rgba(124, 58, 237, 0.5)",
            },
            "&::-webkit-scrollbar-track": {
              background: "transparent",
            },
          },
          html: {
            background:
              process.env.NODE_ENV != "production" ? "#080812" : "transparent",
            "input::-webkit-outer-spin-button, input::-webkit-inner-spin-button":
              {
                WebkitAppearance: "none",
                margin: 0,
              },
          },
          body: {
            position: "absolute",
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            margin: "auto",
            height: "90%",
            width: "85%",
            borderRadius: 6,
            overflow: "hidden",
            paddingRight: "0px !important",
            backgroundColor: "#080812",
            zIndex: -15,
          },
          a: {
            textDecoration: "none",
            color: "#fff",
          },
          "#root": {
            position: "relative",
            zIndex: -10,
          },
          "@keyframes fadeIn": {
            "0%": { opacity: 0 },
            "100%": { opacity: 1 },
          },
        },
      },
    },
  });

  return (
    <StyledEngineProvider injectFirst>
      <ThemeProvider theme={muiTheme}>
        <CssBaseline />
        <HashRouter>
          <Panel />
        </HashRouter>
      </ThemeProvider>
    </StyledEngineProvider>
  );
};
