export default (type) => {
  switch (type) {
    case "dev":
    case "management":
      return admin;
    default:
      return staff;
  }
};

const staff = [
  {
    name: "home",
    icon: ["fas", "house"],
    label: "Dashboard",
    path: "/",
    exact: true,
  },
  {
    name: "players",
    icon: ["fas", "user-large"],
    label: "Online Players",
    path: "/players",
    exact: true,
  },
  {
    name: "disconnected-players",
    icon: ["fas", "user-large-slash"],
    label: "Disconnected Players",
    path: "/disconnected-players",
    exact: true,
  },
  {
    name: "characters",
    icon: ["fas", "users"],
    label: "Find Characters",
    path: "/players-characters",
    exact: true,
  },
  {
    name: "doorlocks",
    icon: ["fas", "door-closed"],
    label: "Doorlocks",
    path: "/doorlocks",
    exact: true,
  },
  { sectionLabel: "Reference" },
  {
    name: "commands",
    icon: ["fas", "terminal"],
    label: "Commands",
    path: "/commands",
    exact: true,
  },
];

const admin = [
  {
    name: "home",
    icon: ["fas", "house"],
    label: "Dashboard",
    path: "/",
    exact: true,
  },
  {
    name: "players",
    icon: ["fas", "user-large"],
    label: "Online Players",
    path: "/players",
    exact: true,
  },
  {
    name: "disconnected-players",
    icon: ["fas", "user-large-slash"],
    label: "Disconnected Players",
    path: "/disconnected-players",
    exact: true,
  },
  {
    name: "characters",
    icon: ["fas", "users"],
    label: "Find Characters",
    path: "/players-characters",
    exact: true,
  },
  {
    name: "vehicles",
    icon: ["fas", "car"],
    label: "Active Vehicles",
    path: "/vehicles",
    exact: true,
  },
  {
    name: "current-vehicle",
    icon: ["fas", "car-side"],
    label: "Current Vehicle",
    path: "/current-vehicle",
    exact: true,
  },
  {
    name: "doorlocks",
    icon: ["fas", "door-closed"],
    label: "Doorlocks",
    path: "/doorlocks",
    exact: true,
  },
  { sectionLabel: "Admin Tools" },
  {
    name: "items",
    icon: ["fas", "box-open"],
    label: "Item Database",
    path: "/items",
    exact: true,
  },
  { sectionLabel: "Reference" },
  {
    name: "commands",
    icon: ["fas", "terminal"],
    label: "Commands",
    path: "/commands",
    exact: true,
  },
];
