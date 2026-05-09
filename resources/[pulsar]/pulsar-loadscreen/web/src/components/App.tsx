import React, { useState, useEffect } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import { LoadingState } from "../types";
import logo from "../images/logo.png";
import image1 from "../images/image_01.png";
import image2 from "../images/image_02.png";
import image3 from "../images/image_03.png";
import image4 from "../images/image_04.png";
import image5 from "../images/image_05.png";
import image6 from "../images/image_06.png";

const backgroundImages = [image1, image2, image3, image4, image5, image6];

const handoverData = window?.nuiHandoverData;

debugData([{ action: "playerData", data: { name: "", priority: 100, priorityMessage: "Management | +100" } }], 100);

debugData([{ eventName: "loadProgress", loadFraction: 0.1 }], 1000);
debugData([{ eventName: "loadProgress", loadFraction: 0.2 }], 2000);
debugData([{ eventName: "loadProgress", loadFraction: 0.3 }], 3000);
debugData([{ eventName: "loadProgress", loadFraction: 0.4 }], 4000);
debugData([{ eventName: "loadProgress", loadFraction: 0.5 }], 5000);
debugData([{ eventName: "loadProgress", loadFraction: 0.6 }], 6000);
debugData([{ eventName: "loadProgress", loadFraction: 0.7 }], 7000);
debugData([{ eventName: "loadProgress", loadFraction: 0.8 }], 8000);
debugData([{ eventName: "loadProgress", loadFraction: 0.9 }], 9000);
debugData([{ eventName: "loadProgress", loadFraction: 1.0 }], 10000);

const initialState: LoadingState = {
  completed: {},
  currentStage: null,
};

const App: React.FC = () => {
  const [playerName, setPlayerName] = useState<string>("Player");
  const [priority, setPriority] = useState<number>(0);
  const [priorityMessage, setPriorityMessage] = useState<string>("");
  const [loadingText, setLoadingText] = useState<string>("Initializing");
  const [loadProgress, setLoadProgress] = useState<number>(0);
  const [currentBgIndex, setCurrentBgIndex] = useState<number>(0);
  const [loadingState, setLoadingState] = useState<LoadingState>(initialState);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (!event.data || typeof event.data !== "object") {
        return;
      }

      const { eventName, action, data } = event.data;
      const eventType = eventName || action;

      if (event.data.eventName === "loadProgress") {
        const loadFraction = event.data.loadFraction;
        const progressPercent = Math.min(loadFraction * 100, 100);
        setLoadProgress(progressPercent);

        if (progressPercent >= 100) {
          setLoadingText("Cleaning up");
        } else if (progressPercent >= 90) {
          setLoadingText("Finalizing");
        } else if (progressPercent >= 80) {
          setLoadingText("Loading textures");
        } else if (progressPercent >= 70) {
          setLoadingText("Loading resources");
        } else if (progressPercent >= 60) {
          setLoadingText("Initializing game");
        } else if (progressPercent >= 50) {
          setLoadingText("Loading data files");
        } else if (progressPercent >= 40) {
          setLoadingText("Loading assets");
        } else if (progressPercent >= 30) {
          setLoadingText("Loading components");
        } else if (progressPercent >= 20) {
          setLoadingText("Initializing");
        } else if (progressPercent >= 10) {
          setLoadingText("Starting");
        } else {
          setLoadingText("Connecting");
        }
        return;
      }

      if (eventType === "playerData") {
        setPlayerName(data.name);
        setPriority(data.priority);
        setPriorityMessage(data.priorityMessage);
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useEffect(() => {
    if (handoverData?.name) {
      setPlayerName(handoverData.name);
    }

    if (handoverData?.priority !== undefined) {
      setPriority(handoverData.priority);
    }

    if (handoverData?.priorityMessage) {
      setPriorityMessage(handoverData.priorityMessage);
    }
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentBgIndex((prev) => {
        const availableIndices = backgroundImages.map((_, index) => index).filter((index) => index !== prev);

        const randomIndex = availableIndices[Math.floor(Math.random() * availableIndices.length)];
        return randomIndex;
      });
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="loading-screen">
      <div
        className="background-slider"
        style={{
          backgroundImage: `url(${backgroundImages[currentBgIndex]})`,
        }}
      />
      <div className="background-overlay" />

      <div className="center-content">
        <img src={logo} alt="Logo" className="logo" />
        <div className="welcome-text">
          <h1 className="player-name">{playerName}</h1>
          <h2 className="welcome-message">
            Welcome to Pulsar Framework
            <span className="dots">
              <span className="dot">.</span>
              <span className="dot">.</span>
              <span className="dot">.</span>
            </span>
          </h2>
        </div>
      </div>

      <div className="bottom-content">
        <div className="loading-info">
          <p className="loading-text">
            {loadingText}
            <span className="dots">
              <span className="dot">.</span>
              <span className="dot">.</span>
              <span className="dot">.</span>
            </span>
          </p>
        </div>
        <div className="progress-bar-container">
          <div className="progress-bar-fill" style={{ width: `${loadProgress}%` }} />
        </div>
      </div>

      <div className="stage-display">
        {Object.keys(loadingState.completed).map((stage) => (
          <span key={stage} className="completed-stage">
            {stage}
          </span>
        ))}
        {loadingState.currentStage ? <span className="current-stage">{loadingState.currentStage}</span> : loadProgress >= 100 ? <span className="current-stage">Loading Assets</span> : null}
      </div>

      {priority > 0 && priorityMessage && (
        <div className="priority-container">
          <div className="priority-section">
            <div className="priority-title">Total Priority: {priority}</div>
            <div className="priority-message">{priorityMessage}</div>
          </div>
        </div>
      )}
    </div>
  );
};

export default App;
