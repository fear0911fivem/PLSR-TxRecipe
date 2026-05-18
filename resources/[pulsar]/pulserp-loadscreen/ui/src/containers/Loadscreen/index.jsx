import React, { useMemo } from "react";
import { useSelector } from "react-redux";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

import bg from "../../assets/background.jpg";
import ServerLogo from "../../assets/server_logo.png";
import DailyTip from "./DailyTip";

function formatStage(stage) {
  if (!stage) return "Initializing";
  return String(stage)
    .replaceAll("_", " ")
    .toLowerCase()
    .replace(/\b\w/g, (m) => m.toUpperCase());
}

export default function Loadscreen() {
  const completed = useSelector((s) => s.load.completed) || {};
  const currentStage = useSelector((s) => s.load.currentStage);
  const test = useSelector((s) => s.load.test) || { total: 1, current: 0 };

  const name = useSelector((s) => s.load.name);
  const priority = useSelector((s) => s.load.priority) || 0;
  const priorityMessage = useSelector((s) => s.load.priorityMessage);

  const percent = useMemo(() => {
    const total = Number(test?.total) || 1;
    const current = Number(test?.current) || 0;
    const p = (current / total) * 100;
    return Math.max(0, Math.min(100, Number.isFinite(p) ? p : 0));
  }, [test]);

  const stageLabel = useMemo(() => formatStage(currentStage), [currentStage]);

  return (
    <div className="relative h-screen w-screen overflow-hidden bg-black text-white">
      <img
        src={bg}
        alt=""
        className="absolute inset-0 h-full w-full object-cover opacity-70"
        draggable={false}
      />
      <div className="absolute inset-0 bg-gradient-to-tr from-black/80 via-black/40 to-black/80" />

      <div className="absolute left-6 top-6 select-none">
        <span className="text-[11px] tracking-[0.22em] text-white/70">
          POWERED BY <span className="text-brand-light">PULSAR FRAMEWORK</span>
        </span>
      </div>

      <div className="absolute right-6 top-6 flex items-center gap-3">
        <a
          href="#"
          className="group inline-flex items-center gap-2 rounded-lg border border-brand-main/35 bg-black/30 px-3 py-2 text-xs text-white/80 backdrop-blur hover:border-white/20 hover:text-white"
          onClick={(e) => e.preventDefault()}
        >
          <FontAwesomeIcon
            icon={["fas", "rocket"]}
            className="text-white/80 group-hover:text-white"
          />
          <span className="stage-mono">Project</span>
        </a>
        <a
          href="#"
          className="group inline-flex items-center gap-2 rounded-lg border border-brand-main/35 bg-black/30 px-3 py-2 text-xs text-white/80 backdrop-blur hover:border-white/20 hover:text-white"
          onClick={(e) => e.preventDefault()}
        >
          <FontAwesomeIcon
            icon={["fab", "discord"]}
            className="text-white/80 group-hover:text-white"
          />
          <span className="stage-mono">Discord</span>
        </a>
      </div>

      <div className="absolute inset-0 grid place-items-center px-6">
        <div className="w-full max-w-3xl">
          <div className="flex flex-col items-center">
            <div className="relative isolate">
              <div
                className="pointer-events-none absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 blur-[80px]"
                style={{
                  width: "140px",
                  height: "260px",
                  background:
                    "linear-gradient(to bottom, rgba(146, 28, 28, 0.35), rgba(28,130,146,0.05))",
                }}
              />

              <img
                src={ServerLogo}
                alt="Server Logo"
                className="relative z-10 h-44 w-auto select-none drop-shadow-[0_24px_60px_rgba(0,0,0,0.55)] animate-soft-float"
                draggable={false}
              />
            </div>

            <div className="mt-8 text-center">
              <div className="text-2xl font-semibold tracking-tight">
                {name ? (
                  <>
                    <span className="text-white/75">Welcome back, </span>
                    <span className="text-white">{name}</span>
                  </>
                ) : (
                  <span className="text-white">Welcome</span>
                )}
              </div>

              <div className="mt-2 stage-mono text-sm text-white/70">
                Loading into server
                <span className="ml-1 inline-flex items-center gap-1 align-middle">
                  <span className="inline-block h-3 w-1 rounded-full bg-white/70 animate-dot-1" />
                  <span className="inline-block h-3 w-1 rounded-full bg-white/70 animate-dot-2" />
                  <span className="inline-block h-3 w-1 rounded-full bg-white/70 animate-dot-3" />
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <DailyTip />

      {priority > 0 && priorityMessage ? (
        <div className="absolute bottom-[72px] right-6 w-[360px] max-w-[calc(100vw-48px)] rounded-2xl border border-brand-main/35 bg-black/35 p-4 backdrop-blur shadow-brand-main-sm">
          <div className="flex items-center justify-between gap-3">
            <div className="stage-mono text-xs tracking-wider text-brand-main">
              PRIORITY BOOST
            </div>
            <div className="stage-mono text-xs text-white/80">
              Total:{" "}
              <span className="font-semibold text-white">{priority}</span>
            </div>
          </div>

          <div className="mt-3 whitespace-pre-wrap text-sm leading-relaxed text-white/80">
            {priorityMessage}
          </div>
        </div>
      ) : null}

      <div className="absolute bottom-0 left-0 right-0 px-6 pb-6 select-none">
        <div className="flex items-center justify-between text-xs">
          <div className="stage-mono tracking-wider text-white/60">
            <span className="text-brand-main">//</span> LOADING
          </div>

          <div className="flex items-center gap-4">
            <div className="stage-mono text-white/80">{stageLabel}</div>
            <div className="stage-mono text-white/60">
              {Math.round(percent)}%
            </div>
          </div>
        </div>

        <div className="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-white/10">
          <div
            className="h-full bg-brand-main transition-[width] duration-300"
            style={{ width: `${percent}%` }}
          />
        </div>
      </div>
    </div>
  );
}
