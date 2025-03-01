const {onSchedule} = require("firebase-functions/v2/scheduler");
const {getFirestore} = require("firebase-admin/firestore");
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const {DateTime} = require("luxon");

// Initialize Firebase Admin SDK
admin.initializeApp();
const firestore = admin.firestore();
const db = getFirestore();

// Define settings for the Cloud Function
const functionSettings = {
    timeoutSeconds: 120,
    memory: "512MB",
    region: "europe-west1",
    minInstances: 0,
    maxInstances: 5,
};

/**
 * Sorts leaderboard and manages the ranks
 * @param {Map} leaderboard
 * @return {Map} sorted leaderboard
 */
function sortLeaderboard(leaderboard) {
    // Sort by totalScore in descending order
    leaderboard.sort((a, b) => b.totalScore - a.totalScore);

    let rank = 1;
    let previousScore = (leaderboard[0] && leaderboard[0].totalScore) || 0;
    for (const user of leaderboard) {
        if (user.totalScore < previousScore) {
            rank++;
            previousScore = user.totalScore;
        }
        user.rank = rank;
    }

    return leaderboard;
}

// Scheduled function to calculate the 30-day leaderboard for community and groups
exports.calculateDailyLeaderboard = onSchedule({schedule: "0 7 * * *", timeZone: "Asia/Jerusalem", ...functionSettings}, async (event) => {
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

            const totalScore = attendanceSnapshot.empty?
                0 :
                attendanceSnapshot.docs.reduce((acc, doc) => acc + (doc.data().score || 0), 0);

            // Add to community leaderboard
            communityLeaderboard.push({
                userId: userId,
                name: `${userData.firstName} ${userData.fatherName} ${userData.lastName}`,
                totalScore: totalScore,
                rank: 0,
            });

            // Add to group-specific leaderboard
            if (groupId && userData.groupId !== "none") {
                if (!groupLeaderboards[groupId]) groupLeaderboards[groupId] = [];
                groupLeaderboards[groupId].push({
                    userId: userId,
                    name: `${userData.firstName} ${userData.fatherName} ${userData.lastName}`,
                    totalScore: totalScore,
                    rank: 0,
                });
            }
        }

        const sortedCommunityLeaderboard = sortLeaderboard(communityLeaderboard);
        // Save community leaderboard
        await firestore.collection("leaderboards").doc("community").set({
            date: new Date(),
            leaderboard: sortedCommunityLeaderboard,
        });

        // Save group-specific leaderboards
        for (const groupId in groupLeaderboards) {
            if (Object.prototype.hasOwnProperty.call(groupLeaderboards, groupId)) {
                const sortedGroupLeaderboard = sortLeaderboard(groupLeaderboards[groupId]);
                await firestore.collection("leaderboards").doc(groupId).set({
                    date: new Date(),
                    leaderboard: sortedGroupLeaderboard,
                });
            }
        }

        console.log("Leaderboard calculation completed successfully.");
    } catch (error) {
        console.error("Error calculating leaderboard:", error);
    }
});

// Function to calculate the 30-day leaderboard for community and groups immediately
exports.calculateLeaderboardNow = functions.https.onCall(
    {
        ...functionSettings,
    },
    async (req, context) => {
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

                const totalScore = attendanceSnapshot.empty?
                    0 :
                    attendanceSnapshot.docs.reduce((acc, doc) => acc + (doc.data().score || 0), 0);

                // Add to community leaderboard
                communityLeaderboard.push({
                    userId: userId,
                    name: `${userData.firstName} ${userData.fatherName} ${userData.lastName}`,
                    totalScore: totalScore,
                    rank: 0,
                });

                // Add to group-specific leaderboard
                if (groupId && userData.groupId !== "none") {
                    if (!groupLeaderboards[groupId]) groupLeaderboards[groupId] = [];
                    groupLeaderboards[groupId].push({
                        userId: userId,
                        name: `${userData.firstName} ${userData.fatherName} ${userData.lastName}`,
                        totalScore: totalScore,
                        rank: 0,
                    });
                }
            }

            const sortedCommunityLeaderboard = sortLeaderboard(communityLeaderboard);

            // Save community leaderboard
            await firestore.collection("leaderboards").doc("community").set({
                date: new Date(),
                leaderboard: sortedCommunityLeaderboard,
            });

            // Save group-specific leaderboards
            for (const groupId in groupLeaderboards) {
                if (Object.prototype.hasOwnProperty.call(groupLeaderboards, groupId)) {
                    const sortedGroupLeaderboard = sortLeaderboard(groupLeaderboards[groupId]);
                    await firestore.collection("leaderboards").doc(groupId).set({
                        date: new Date(),
                        leaderboard: sortedGroupLeaderboard,
                    });
                }
            }
        } catch (error) {
            throw new functions.https.HttpsError("internal", "Error calculating leaderboard." + error);
        }
    },
);

// Cloud function to calculate the leaderboard based on time and group
exports.calculateLeaderboard = functions.https.onCall(
    {
        ...functionSettings,
        minInstances: 1,
    },
    async (req, context) => {
        console.log(req.data);
        const {startDate, endDate, groupId} = req.data;

        try {
            if (!startDate || !endDate) {
                throw new functions.https.HttpsError(
                    "invalid-argument",
                    "Start date and end date are required.",
                );
            }

            // Convert the start and end date to Firestore Timestamps using the provided format
            const start = DateTime.fromFormat(startDate, "yyyy-MM-dd HH:mm:ss.SSS", {zone: "Asia/Jerusalem"});
            const end = DateTime.fromFormat(endDate, "yyyy-MM-dd HH:mm:ss.SSS", {zone: "Asia/Jerusalem"});
            if (!start.isValid || !end.isValid) {
                throw new functions.https.HttpsError(
                    "invalid-argument",
                    "Invalid date format. Please provide a valid date string in the format 'yyyy-MM-dd HH:mm:ss.SSS'.",
                );
            }

            const startTimestamp = admin.firestore.Timestamp.fromMillis(start.toMillis());
            const endTimestamp = admin.firestore.Timestamp.fromMillis(end.toMillis());

            // Reference to users collection
            let usersQuery = db.collection("users");

            // Filter by group if groupId is provided
            if (groupId && groupId !== "all") {
                usersQuery = usersQuery.where("groupId", "==", groupId);
            }

            const usersSnapshot = await usersQuery.get();
            if (usersSnapshot.empty) {
                throw new functions.https.HttpsError(
                    "not-found",
                    "No users found for the given criteria.",
                );
            }

            const leaderboard = [];

            // Iterate through each user to calculate their score
            for (const userDoc of usersSnapshot.docs) {
                const userData = userDoc.data();
                const attendanceQuery = db
                    .collection("users")
                    .doc(userDoc.id)
                    .collection("attendance")
                    .where("date", ">=", startTimestamp)
                    .where("date", "<=", endTimestamp);

                const attendanceSnapshot = await attendanceQuery.get();
                let totalScore = 0;

                if (attendanceSnapshot.empty) {
                    continue;
                }

                attendanceSnapshot.forEach((attendanceDoc) => {
                    totalScore += attendanceDoc.data().score;
                });

                leaderboard.push({
                    userId: userDoc.id,
                    name: userData.firstName + " " + userData.fatherName + " " + userData.lastName,
                    grade: userData.grade,
                    group: userData.groupId,
                    totalScore: totalScore,
                });
            }

            const sortedLeaderboard = sortLeaderboard(leaderboard);

            return sortedLeaderboard;
        } catch (error) {
            throw new functions.https.HttpsError("internal", "Error calculating leaderboard." + error);
        }
    },
);
