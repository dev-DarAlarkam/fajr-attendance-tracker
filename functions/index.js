const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {getFirestore} = require("firebase-admin/firestore");
const admin = require("firebase-admin");
const cors = require("cors")({origin: true}); // Import and configure CORS


// Initialize Firebase Admin SDK
admin.initializeApp();
const firestore = admin.firestore();
const db = getFirestore();

// Function to test Firestore connection
exports.testConnection = onRequest({cors: true}, async (req, res) => {
    try {
        const testDoc = await firestore.collection("test").doc("testDoc").get();
        if (!testDoc.exists) {
            res.status(404).send("No document found!");
        } else {
            res.status(200).send("Connection successful! Document data: " + JSON.stringify(testDoc.data()));
        }
    } catch (error) {
        res.status(500).send("Error connecting to Firestore: " + error.message);
    }
});

// Function to fetch users and attendance data for the last 30 days
exports.fetchUsersAndAttendance = onRequest({cors: true}, async (req, res) => {
    const today = new Date();
    const startDate = new Date();
    startDate.setDate(today.getDate() - 30);

    try {
        const usersSnapshot = await firestore.collection("users").get();
        const attendanceData = [];

        for (const userDoc of usersSnapshot.docs) {
            if (!userDoc.exists) continue;
            const userId = userDoc.id;
            const userData = userDoc.data();

            const attendanceSnapshot = await firestore.collection("users").doc(userId).collection("attendance")
                .where("date", ">=", admin.firestore.Timestamp.fromDate(startDate))
                .where("date", "<=", admin.firestore.Timestamp.fromDate(today))
                .get();

            let totalScore;
            if (!attendanceSnapshot.empty) {
                totalScore = attendanceSnapshot.docs.reduce((acc, doc) => acc + (doc.data().score || 0), 0);
            } else {
                const olderAttendanceSnapshot = await firestore.collection("users").doc(userId).collection("attendance").get();
                if (olderAttendanceSnapshot.empty) {
                    totalScore = "N/A";
                } else {
                    totalScore = 0;
                }
            }

            attendanceData.push({
                userId: userId,
                name: `${userData.firstName} ${userData.fatherName} ${userData.lastName}`,
                totalScore: totalScore,
            });
        }

        // Sort attendanceData by totalScore in descending order
        attendanceData.sort((a, b) => b.totalScore - a.totalScore);

        res.status(200).send(attendanceData);
    } catch (error) {
        res.status(500).send("Error fetching users or attendance data: " + error.message);
    }
});

// Scheduled function to calculate the 30-day leaderboard for community and groups
exports.calculateDailyLeaderboard = onSchedule({schedule: "0 7 * * *", timeZone: "Asia/Jerusalem"}, async (event) => {
    const today = new Date();
    const startDate = new Date();
    startDate.setDate(today.getDate() - 30);

    try {
        const usersSnapshot = await firestore.collection("users").get();
        const communityLeaderboard = [];
        const groupLeaderboards = {};

        for (const userDoc of usersSnapshot.docs) {
            const userId = userDoc.id;
            const userData = userDoc.data();
            const groupId = userData.groupId;

            const attendanceSnapshot = await firestore.collection("users").doc(userId).collection("attendance")
                .where("date", ">=", admin.firestore.Timestamp.fromDate(startDate))
                .where("date", "<=", admin.firestore.Timestamp.fromDate(today))
                .get();
            let totalScore;
            if (!attendanceSnapshot.empty) {
                totalScore = attendanceSnapshot.docs.reduce((acc, doc) => acc + (doc.data().score || 0), 0);
            } else {
                const olderAttendanceSnapshot = await firestore.collection("users").doc(userId).collection("attendance").get();
                if (olderAttendanceSnapshot.empty) {
                    totalScore = "N/A";
                } else {
                    totalScore = 0;
                }
            }

            // Add to community leaderboard
            communityLeaderboard.push({
                userId: userId,
                name: `${userData.firstName} ${userData.fatherName} ${userData.lastName}`,
                totalScore: totalScore,
            });

            // Add to group-specific leaderboard
            if (groupId && userData.groupId !== "None") {
                if (totalScore !== "N/A") {
                    if (!groupLeaderboards[groupId]) groupLeaderboards[groupId] = [];
                    groupLeaderboards[groupId].push({
                        userId: userId,
                        name: `${userData.firstName} ${userData.lastName}`,
                        totalScore: totalScore,
                    });
                }
            }
        }

        // Sort leaderboards
        communityLeaderboard.sort((a, b) => b.totalScore - a.totalScore);

        // Save community leaderboard
        await firestore.collection("leaderboards").doc("community").set({
            date: new Date(),
            leaderboard: communityLeaderboard,
        });

        // Save group-specific leaderboards
        for (const groupId in groupLeaderboards) {
            if (Object.prototype.hasOwnProperty.call(groupLeaderboards, groupId)) {
                groupLeaderboards[groupId].sort((a, b) => b.totalScore - a.totalScore);
                await firestore.collection("leaderboards").doc(groupId).set({
                    date: new Date(),
                    leaderboard: groupLeaderboards[groupId],
                });
            }
        }

        console.log("Leaderboard calculation completed successfully.");
    } catch (error) {
        console.error("Error calculating leaderboard:", error);
    }
});

// Function to calculate the 30-day leaderboard for community and groups immediately
exports.calculateLeaderboardNow = onRequest({cors: true}, async (req, res) => {
    cors(req, res, async () => {
        const today = new Date();
        const startDate = new Date();
        startDate.setDate(today.getDate() - 30);

        try {
            const usersSnapshot = await firestore.collection("users").get();
            const communityLeaderboard = [];
            const groupLeaderboards = {};

            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                const userData = userDoc.data();
                const groupId = userData.groupId;

                const attendanceSnapshot = await firestore.collection("users").doc(userId).collection("attendance")
                    .where("date", ">=", admin.firestore.Timestamp.fromDate(startDate))
                    .where("date", "<=", admin.firestore.Timestamp.fromDate(today))
                    .get();
                let totalScore;
                if (!attendanceSnapshot.empty) {
                    totalScore = attendanceSnapshot.docs.reduce((acc, doc) => acc + (doc.data().score || 0), 0);
                } else {
                    const olderAttendanceSnapshot = await firestore.collection("users").doc(userId).collection("attendance").get();
                    if (olderAttendanceSnapshot.empty) {
                        totalScore = "N/A";
                    } else {
                        totalScore = 0;
                    }
                }

                // Add to community leaderboard
                communityLeaderboard.push({
                    userId: userId,
                    name: `${userData.firstName} ${userData.fatherName} ${userData.lastName}`,
                    totalScore: totalScore,
                });

                // Add to group-specific leaderboard
                if (groupId && userData.groupId !== "None") {
                    if (totalScore !== "N/A") {
                        if (!groupLeaderboards[groupId]) groupLeaderboards[groupId] = [];
                        groupLeaderboards[groupId].push({
                            userId: userId,
                            name: `${userData.firstName} ${userData.lastName}`,
                            totalScore: totalScore,
                        });
                    }
                }
            }

            // Sort leaderboards
            communityLeaderboard.sort((a, b) => b.totalScore - a.totalScore);

            // Save community leaderboard
            await firestore.collection("leaderboards").doc("community").set({
                date: new Date(),
                leaderboard: communityLeaderboard,
            });
            console.log("finished community");
            // Save group-specific leaderboards
            for (const groupId in groupLeaderboards) {
                if (Object.prototype.hasOwnProperty.call(groupLeaderboards, groupId)) {
                    console.log("before group sort " + groupId);
                    groupLeaderboards[groupId].sort((a, b) => b.totalScore - a.totalScore);
                    console.log("before group upload " + groupId);
                    await firestore.collection("leaderboards").doc(groupId).set({
                        date: new Date(),
                        leaderboard: groupLeaderboards[groupId],
                    });
                    console.log("after group upload " + groupId);
                }
            }

            console.log("Leaderboard calculation completed successfully.");
            res.status(200).send({data: communityLeaderboard});
        } catch (error) {
            console.error("Error calculating leaderboard:", error);
            res.status(500).send({error: "Error calculating leaderboard: " + error.message});
        }
    });
});

// Cloud function to calculate the leaderboard based on time and group
exports.calculateLeaderboard = onRequest({cors: true}, async (req, res) => {
    try {
        const {startDate, endDate, groupId} = req.body;

        if (!startDate || !endDate) {
            return res.status(400).send("Start date and end date are required.");
        }

        // Convert the start and end date to Firestore Timestamps
        const start = new Date(startDate);
        const end = new Date(endDate);

        // Reference to users collection
        let usersQuery = db.collection("users");

        // Filter by group if groupId is provided
        if (groupId && groupId !== "all") {
            usersQuery = usersQuery.where("groupId", "==", groupId);
        }

        const usersSnapshot = await usersQuery.get();
        if (usersSnapshot.empty) {
            return res.status(404).send("No users found for the given criteria.");
        }

        const leaderboard = [];

        // Iterate through each user to calculate their score
        for (const userDoc of usersSnapshot.docs) {
            const userData = userDoc.data();
            const attendanceQuery = db
                .collection("users")
                .doc(userDoc.id)
                .collection("attendance")
                .where("date", ">=", start)
                .where("date", "<=", end);

            const attendanceSnapshot = await attendanceQuery.get();
            let totalScore = 0;

            if (!attendanceSnapshot.empty) {
                attendanceSnapshot.forEach((attendanceDoc) => {
                    totalScore += attendanceDoc.data().score;
                });
            }

            leaderboard.push({
                userId: userDoc.id,
                name: userData.firstName + " " + userData.fatherName + " " + userData.lastName,
                grade: userData.grade,
                group: userData.groupId,
                totalScore: totalScore,
            });
        }

        // Sort leaderboard by total score in descending order
        leaderboard.sort((a, b) => b.totalScore - a.totalScore);

        // Assign rank (handle ties)
        let rank = 1;
        let previousScore = leaderboard.length > 0 ? leaderboard[0].totalScore : 0;
        for (let i = 0; i < leaderboard.length; i++) {
            if (i > 0 && leaderboard[i].totalScore < previousScore) {
                rank = i + 1;
            }
            leaderboard[i].rank = rank;
            previousScore = leaderboard[i].totalScore;
        }

        return res.status(200).json(leaderboard);
    } catch (error) {
        console.error("Error calculating leaderboard: ", error);
        return res.status(500).send("Internal Server Error");
    }
});
