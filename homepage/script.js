// script.js

// Update the profile picture using the configured variable
document.getElementById("profilePic").src = PFP_URL;

// Function to update the greeting message without typing animation
function updateGreeting() {
    const now = new Date();
    const hour = now.getHours();
    let greetingText = "";
    if (hour <= 3) {
        greetingText = `Late Night session, ${USERNAME}? 🌑`;
    } else if (hour <= 6) {
        greetingText = `You woke me up, ${USERNAME}? Already awake? 🌕`;
    } else if (hour <= 9) {
        greetingText = `Good Morning ${USERNAME}, how was your night? ⛅️`;
    } else if (hour <= 18) {
        greetingText = `Glad to see you, ${USERNAME}! How is it going? ☀️`;
    } else if (hour <= 20) {
        greetingText = `How was your day, ${USERNAME}? 🌆`;
    } else if (hour <= 22) {
        greetingText = `Good Evening, ${USERNAME}. Have you had dinner? 🌇`;
    } else {
        greetingText = `Good Night, ${USERNAME}. Are you going to sleep? 🌙`;
    }
    // Wrap the username in a span with a glowing effect
    greetingText = greetingText.replace(USERNAME, `<span class="username">${USERNAME}</span>`);
    document.getElementById("greeting").innerHTML = greetingText;
}

updateGreeting();

// Refresh the pywal CSS file periodically to reflect any wallpaper changes
function refreshPywal() {
    const pywalLink = document.getElementById("pywal");
    pywalLink.href = "file:///home/woozy/.cache/wal/colors.css?v=" + new Date().getTime();
}
setInterval(refreshPywal, 60000);
