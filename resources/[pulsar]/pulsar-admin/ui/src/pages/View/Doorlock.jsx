import React, { useEffect, useState } from "react";
import { useHistory, useParams } from "react-router-dom";
import { Grid, TextField, Button, Paper, Typography, Switch, FormControlLabel, Chip, MenuItem } from "@material-ui/core";
import { makeStyles } from "@material-ui/styles";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

import Nui from "../../util/Nui";
import { Loader, Modal } from "../../components";

const useStyles = makeStyles((theme) => ({
  wrapper: {
    padding: 20,
    height: "100%",
    overflowY: "auto",
  },
  paper: {
    padding: 20,
    marginBottom: 20,
    background: theme.palette.secondary.main,
  },
  header: {
    marginBottom: 20,
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  title: {
    fontSize: 24,
    fontWeight: 600,
  },
  field: {
    marginBottom: 15,
  },
  buttonGroup: {
    display: "flex",
    gap: 10,
  },
  deleteButton: {
    background: theme.palette.error.main,
    "&:hover": {
      background: theme.palette.error.dark,
    },
  },
  stateChip: {
    fontSize: 16,
    padding: "8px 16px",
    height: "auto",
  },
}));

export default () => {
  const classes = useStyles();
  const history = useHistory();
  const { id } = useParams();
  const isNew = id === "new";

  const [loading, setLoading] = useState(!isNew);
  const [groupsInput, setGroupsInput] = useState("");
  const [doorlock, setDoorlock] = useState({
    name: "",
    state: 1,
    coords: { x: 0, y: 0, z: 0 },
    heading: 0,
    model: "",
    maxDistance: 2.5,
    auto: false,
    lockpick: false,
    hideUi: false,
    holdOpen: false,
    groups: {},
    characters: [],
    items: [],
    passcode: null,
    lockSound: "",
    unlockSound: "",
    doorRate: 1.0,
    workplace: "",
    permissions: "",
    onduty: false,
  });
  const [showDeleteModal, setShowDeleteModal] = useState(false);

  useEffect(() => {
    if (!isNew) {
      fetchDoorlock();
    }
  }, [id]);

  useEffect(() => {
    const handleMessage = (event) => {
      if (event.data.type === "DOORLOCK_DOORS_SELECTED") {
        const selectedData = event.data.data;
        setDoorlock((prev) => ({
          ...prev,
          model: selectedData.model || prev.model,
          coords: selectedData.coords || prev.coords,
          heading: selectedData.heading || prev.heading,
          doors: selectedData.doors || prev.doors,
        }));
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  const fetchDoorlock = async () => {
    setLoading(true);
    try {
      let res = await (await Nui.send("GetDoorLockById", { id: parseInt(id) })).json();
      if (res) {
        setDoorlock(res);
        setGroupsInput(formatGroupsForDisplay(res.groups || {}));
      }
    } catch (e) {
      console.error("Failed to fetch doorlock", e);
    }
    setLoading(false);
  };

  const handleSave = async () => {
    try {
      const endpoint = isNew ? "CreateDoorLock" : "UpdateDoorLock";

      const payload = isNew ? doorlock : { ...doorlock, id: parseInt(id) };

      const res = await (await Nui.send(endpoint, payload)).json();

      if (res && res.success) {
        history.push("/doorlocks");
      }
    } catch (e) {
      console.error("Failed to save doorlock", e);
    }
  };

  const handleDelete = async () => {
    try {
      const res = await (await Nui.send("DeleteDoorLock", { id: parseInt(id) })).json();

      if (res && res.success) {
        history.push("/doorlocks");
      }
    } catch (e) {
      console.error("Failed to delete doorlock", e);
    }
  };

  const handleTeleport = async () => {
    try {
      await Nui.send("TeleportToDoorLock", { id: parseInt(id) });
    } catch (e) {
      console.error("Failed to teleport to doorlock", e);
    }
  };

  const handleToggleState = async () => {
    const newState = doorlock.state === 1 ? 0 : 1;
    try {
      const res = await (
        await Nui.send("ToggleDoorLockState", {
          id: parseInt(id),
          state: newState,
        })
      ).json();

      if (res && res.success) {
        setDoorlock({ ...doorlock, state: newState });
      }
    } catch (e) {
      console.error("Failed to toggle doorlock state", e);
    }
  };

  const handleStartAddDoor = async (isDouble) => {
    try {
      await Nui.send("StartAddDoorLock", { isDouble });
    } catch (e) {
      console.error("Failed to start add door", e);
    }
  };

  const updateField = (field, value) => {
    setDoorlock({ ...doorlock, [field]: value });
  };

  const updateCoords = (coord, value) => {
    setDoorlock({
      ...doorlock,
      coords: { ...doorlock.coords, [coord]: parseFloat(value) || 0 },
    });
  };

  const parseGroupsInput = (input) => {
    if (!input || input.trim() === "") return {};

    try {
      return JSON.parse(input);
    } catch (e) {
      const groups = {};

      const pairs = input
        .split(/[,;\n]/)
        .map((pair) => pair.trim())
        .filter((pair) => pair);

      pairs.forEach((pair) => {
        if (pair.includes("=")) {
          const [key, value] = pair.split("=").map((s) => s.trim());
          const cleanKey = key.replace(/['"]/g, "");
          const cleanValue = parseInt(value.trim());
          if (cleanKey && !isNaN(cleanValue)) {
            groups[cleanKey] = cleanValue;
          }
        }
      });

      return groups;
    }
  };

  const formatGroupsForDisplay = (groups) => {
    if (!groups || Object.keys(groups).length === 0) return "";
    return Object.entries(groups)
      .map(([key, value]) => `${key} = ${value}`)
      .join(", ");
  };

  if (loading) {
    return (
      <div className={classes.wrapper}>
        <Loader text="Loading Doorlock" />
      </div>
    );
  }

  return (
    <div className={classes.wrapper}>
      <Paper className={classes.paper}>
        <div className={classes.header}>
          <Typography className={classes.title}>{isNew ? "Create New Doorlock" : `Edit Doorlock #${id}`}</Typography>
          {!isNew && <Chip className={classes.stateChip} label={doorlock.state === 1 ? "Locked" : "Unlocked"} color={doorlock.state === 1 ? "error" : "primary"} onClick={handleToggleState} />}
        </div>

        <Grid container spacing={2}>
          <Grid item xs={12}>
            <Typography variant="h6">Basic Information</Typography>
          </Grid>
          <Grid item xs={6}>
            <TextField fullWidth label="Name" value={doorlock.name} onChange={(e) => updateField("name", e.target.value)} className={classes.field} />
          </Grid>
          <Grid item xs={3}>
            <TextField fullWidth label="Max Distance" type="number" value={doorlock.maxDistance} onChange={(e) => updateField("maxDistance", parseFloat(e.target.value))} className={classes.field} />
          </Grid>
          <Grid item xs={3}>
            <TextField fullWidth label="Door Rate" type="number" value={doorlock.doorRate || 1.0} onChange={(e) => updateField("doorRate", parseFloat(e.target.value))} className={classes.field} />
          </Grid>

          <Grid item xs={12}>
            <Typography variant="h6">{doorlock.doors ? "Door Coordinates" : "Coordinates"}</Typography>
          </Grid>
          {isNew && (
            <Grid item xs={12}>
              <div className={classes.buttonGroup}>
                <Button variant="contained" color="primary" onClick={() => handleStartAddDoor(false)}>
                  Select Single Door
                </Button>
                <Button variant="contained" color="primary" onClick={() => handleStartAddDoor(true)}>
                  Select Double Door
                </Button>
              </div>
            </Grid>
          )}

          {doorlock.doors && doorlock.doors.length === 2 ? (
            <>
              <Grid item xs={12}>
                <Typography variant="subtitle1" style={{ fontWeight: 600, marginTop: 10, color: "#E5A502" }}>
                  Door 1
                </Typography>
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="X" type="number" value={parseFloat(doorlock.doors[0]?.coords?.x || 0).toFixed(2)} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Y" type="number" value={parseFloat(doorlock.doors[0]?.coords?.y || 0).toFixed(2)} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Z" type="number" value={parseFloat(doorlock.doors[0]?.coords?.z || 0).toFixed(2)} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Heading" type="number" value={doorlock.doors[0]?.heading || 0} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
              <Grid item xs={12}>
                <TextField fullWidth label="Model Hash" value={doorlock.doors[0]?.model || ""} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>

              <Grid item xs={12}>
                <Typography variant="subtitle1" style={{ fontWeight: 600, marginTop: 10, color: "#E5A502" }}>
                  Door 2
                </Typography>
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="X" type="number" value={parseFloat(doorlock.doors[1]?.coords?.x || 0).toFixed(2)} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Y" type="number" value={parseFloat(doorlock.doors[1]?.coords?.y || 0).toFixed(2)} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Z" type="number" value={parseFloat(doorlock.doors[1]?.coords?.z || 0).toFixed(2)} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Heading" type="number" value={doorlock.doors[1]?.heading || 0} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
              <Grid item xs={12}>
                <TextField fullWidth label="Model Hash" value={doorlock.doors[1]?.model || ""} InputProps={{ readOnly: true }} className={classes.field} />
              </Grid>
            </>
          ) : (
            <>
              <Grid item xs={3}>
                <TextField fullWidth label="X" type="number" value={parseFloat(doorlock.coords?.x || 0).toFixed(2)} onChange={(e) => updateCoords("x", e.target.value)} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Y" type="number" value={parseFloat(doorlock.coords?.y || 0).toFixed(2)} onChange={(e) => updateCoords("y", e.target.value)} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Z" type="number" value={parseFloat(doorlock.coords?.z || 0).toFixed(2)} onChange={(e) => updateCoords("z", e.target.value)} className={classes.field} />
              </Grid>
              <Grid item xs={3}>
                <TextField fullWidth label="Heading" type="number" value={doorlock.heading || 0} onChange={(e) => updateField("heading", parseFloat(e.target.value))} className={classes.field} />
              </Grid>
            </>
          )}

          {!doorlock.doors && (
            <Grid item xs={12}>
              <TextField fullWidth label="Model Hash" value={doorlock.model || ""} onChange={(e) => updateField("model", e.target.value)} className={classes.field} />
            </Grid>
          )}

          <Grid item xs={12}>
            <Typography variant="h6">Options</Typography>
          </Grid>
          <Grid item xs={3}>
            <FormControlLabel control={<Switch checked={doorlock.auto || false} onChange={(e) => updateField("auto", e.target.checked)} />} label="Auto Door" />
          </Grid>
          <Grid item xs={3}>
            <FormControlLabel control={<Switch checked={doorlock.lockpick || false} onChange={(e) => updateField("lockpick", e.target.checked)} />} label="Lockpickable" />
          </Grid>
          <Grid item xs={3}>
            <FormControlLabel control={<Switch checked={doorlock.hideUi || false} onChange={(e) => updateField("hideUi", e.target.checked)} />} label="Hide UI" />
          </Grid>
          <Grid item xs={3}>
            <FormControlLabel control={<Switch checked={doorlock.holdOpen || false} onChange={(e) => updateField("holdOpen", e.target.checked)} />} label="Hold Open" />
          </Grid>
          <Grid item xs={3}>
            <FormControlLabel control={<Switch checked={doorlock.passcode !== null && doorlock.passcode !== undefined} onChange={(e) => updateField("passcode", e.target.checked ? "" : null)} />} label="Passcode Protected" />
          </Grid>
          {doorlock.passcode !== null && doorlock.passcode !== undefined && (
            <Grid item xs={12}>
              <TextField fullWidth label="Passcode" value={doorlock.passcode || ""} onChange={(e) => updateField("passcode", e.target.value)} placeholder="Enter numeric passcode" helperText="Enter a numeric code that users must input to unlock" className={classes.field} />
            </Grid>
          )}

          <Grid item xs={12}>
            <Typography variant="h6">Access Control</Typography>
          </Grid>
          <Grid item xs={12}>
            <TextField
              fullWidth
              label="Groups (e.g., police = 0, ems = 1)"
              value={groupsInput}
              onChange={(e) => {
                setGroupsInput(e.target.value);
                const parsed = parseGroupsInput(e.target.value);
                updateField("groups", parsed);
              }}
              placeholder="police = 0, ems = 1"
              helperText="Enter job groups and minimum grades. Examples: 'police = 0, ems = 1' or 'police=0;ems=1' or JSON format. Leave empty for public access."
              className={classes.field}
              multiline
              rows={2}
            />
          </Grid>
          <Grid item xs={4}>
            <TextField fullWidth label="Workplace (Optional)" value={doorlock.workplace || ""} onChange={(e) => updateField("workplace", e.target.value)} placeholder="lspd" helperText="Specific workplace requirement" className={classes.field} />
          </Grid>
          <Grid item xs={4}>
            <TextField fullWidth label="Permissions (Optional)" value={doorlock.permissions || ""} onChange={(e) => updateField("permissions", e.target.value)} placeholder="manage_doors" helperText="Required permission" className={classes.field} />
          </Grid>
          <Grid item xs={4}>
            <FormControlLabel control={<Switch checked={doorlock.onduty || false} onChange={(e) => updateField("onduty", e.target.checked)} />} label="Require On Duty" />
          </Grid>

          <Grid item xs={12}>
            <Typography variant="h6">Sounds</Typography>
          </Grid>
          <Grid item xs={6}>
            <TextField fullWidth label="Lock Sound" value={doorlock.lockSound || ""} onChange={(e) => updateField("lockSound", e.target.value)} className={classes.field} />
          </Grid>
          <Grid item xs={6}>
            <TextField fullWidth label="Unlock Sound" value={doorlock.unlockSound || ""} onChange={(e) => updateField("unlockSound", e.target.value)} className={classes.field} />
          </Grid>

          <Grid item xs={12}>
            <div className={classes.buttonGroup}>
              <Button variant="contained" color="primary" onClick={handleSave}>
                <FontAwesomeIcon icon={["fas", "save"]} style={{ marginRight: 8 }} />
                {isNew ? "Create" : "Save Changes"}
              </Button>
              {!isNew && (
                <>
                  <Button variant="contained" onClick={handleTeleport}>
                    <FontAwesomeIcon icon={["fas", "location-arrow"]} style={{ marginRight: 8 }} />
                    Teleport
                  </Button>
                  <Button variant="contained" className={classes.deleteButton} onClick={() => setShowDeleteModal(true)}>
                    <FontAwesomeIcon icon={["fas", "trash"]} style={{ marginRight: 8 }} />
                    Delete
                  </Button>
                </>
              )}
              <Button variant="outlined" onClick={() => history.push("/doorlocks")}>
                Cancel
              </Button>
            </div>
          </Grid>
        </Grid>
      </Paper>

      {showDeleteModal && (
        <Modal open={showDeleteModal} title="Delete Doorlock" onAccept={handleDelete} onClose={() => setShowDeleteModal(false)} acceptText="Delete">
          Are you sure you want to delete this doorlock? This action cannot be undone.
        </Modal>
      )}
    </div>
  );
};
