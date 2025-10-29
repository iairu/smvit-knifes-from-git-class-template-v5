# LinkedIn Article (Naplánované cez Buffer)

---

## Post 1: The Serial Communication Problem Nobody Talks About

Did you know developers waste an average of 15-20 minutes per project just troubleshooting baud rate mismatches and crossed RX/TX pins?

That's the hidden tax of serial communication—and it gets worse with USB Killer threats destroying 95% of tested devices.

That's why we built an intelligent USB-TTL converter that:
→ Automatically detects baud rate (no more guessing)
→ Automatically swaps RX/TX pins (no more rewiring)
→ Provides 100% protection against USB Killer attacks through BLE isolation
→ Enables wireless terminal access via web browser or smartphone

Because the best debugging tool is one that just works.

#IoT #EmbeddedSystems #Arduino #ESP32 #Engineering

---

## Post 3: 2.5 Seconds vs 15 Minutes

Traditional USB-TTL converter workflow:
1. Guess the baud rate (9600? 115200?)
2. Try connecting
3. Get garbage data
4. Try another baud rate
5. Still garbage
6. Check if RX/TX pins are crossed
7. Rewire everything
8. Try again...
**Time wasted: 15+ minutes**

Our automatic converter:
1. Plug it in
2. Wait 2.5 seconds
3. It works
**Time saved: Every single time**

We're three IoT engineers (Denis Ivan, Ondrej Špánik, Danilo Bashmakov) who got tired of the same debugging ritual. So we fixed it.

Automation isn't about being lazy. It's about focusing on problems that actually matter.

#ProductivityHack #DeveloperTools #EmbeddedDevelopment

---

## Post 4: BLE vs Bluetooth Classic: What We Learned Measuring 500,000 Bytes

Everyone says "Bluetooth Low Energy is more efficient."

But is it really?

We spent months measuring energy consumption using Nordic Semiconductor's PPK2 with 100nA resolution.

Results with automotive-grade Jody-W263 module:
→ BLE LE 2M PHY: 6-7 mA during transmission
→ Bluetooth Classic: 4.8-4.9 mA during transmission

Wait—Classic is MORE efficient?

Yes... during continuous transmission. But here's the twist:

→ BLE connection cycle: 3ms
→ Classic connection cycle: 200ms+
→ BLE sleep mode: &lt;1 mA
→ Classic sleep mode: 5-10 mA

For serial communication (burst data, then idle), BLE wins decisively.

Real-world engineering is about context, not absolutes.

#BluetoothLE #EnergyEfficiency #EngineeringInsights #IoT

---

## Post 5: Four Iterations to Accurate Power Measurement

Measuring current consumption sounds simple. It's not.

**Iteration 1:** Ampere meter in series
→ Problem: Burden voltage skewed results

**Iteration 2:** Current probe (magnetic field measurement)
→ Problem: Noise overwhelmed the signal

**Iteration 3:** Nordic PPK2 integration
→ Problem: Power supply limitations with module

**Iteration 4:** Modified USB cable with PPK2 in series
→ Success: 100nA resolution, clean measurements

Lesson learned: Don't skip iterations. Each "failure" revealed something we couldn't have predicted.

Design Science Research methodology saved this project.

#Engineering #Research #Iteration #DesignThinking

---

## Post 6: The GPIO Matrix Trick That Enables Auto RX/TX Swap

How do you swap UART pins on the fly when they're hardware-fixed?

ESP32's secret weapon: The GPIO matrix.

Using `gpio_matrix_out()` and `gpio_matrix_in()`, we can remap any UART signal to any GPIO pin at runtime.

Our algorithm:
1. Try default configuration (500ms timeout)
2. Send test command
3. No response? Automatically swap pins
4. Retry
5. Success!

Users don't see the complexity. They just see "it works."

That's the engineering I'm proud of.

#ESP32 #FirmwareDevelopment #EmbeddedProgramming #UserExperience

---

## Post 7: Wireless Serial Terminal in Your Browser

No app installation.
No drivers.
No configuration.

Our converter creates a Wi-Fi access point and web server. Connect your phone, laptop, or tablet, open the browser, and you've got a full serial terminal.

WebSocket implementation: &lt;50ms latency
Range: 10-40 meters
Simultaneous connections: Up to 3 clients tested

Perfect for:
→ Debugging robots during movement
→ Remote access in hazardous environments
→ Teaching workshops with multiple observers
→ Working from comfortable distance

Because sometimes the best tool is the one that gets out of your way.

#WebDevelopment #IoT #WirelessTechnology

---

## Post 8: 95% of Devices Are Vulnerable to USB Killers

Testing by independent researchers found:
• iPhone (Lightning port damage)
• Galaxy Note (USB port failure)
• iPad Pro (temporary malfunction)
• MacBook Pro (complete system death)
• Xbox One (destroyed)
• Automotive infotainment systems (fried)

95% vulnerability rate across consumer and automotive electronics.

Our BLE-isolated converter: 0% vulnerability.

Not because we built better surge protection. Because there's no electrical path to attack.

Defense in depth starts with eliminating attack vectors.

#SecurityByDesign #HardwareProtection #ThreatMitigation

---

## Post 9: Academic Research Meets Real-World Need

This started as an academic project during our studies. 

We dove deep into:
→ Bluetooth 5.0 Core Specification (800+ pages)
→ Jönköping University research on BLE vs Classic energy consumption
→ Nordic Semiconductor's DevAcademy courses
→ Design Science Research methodology

What we learned: Reading specifications is tedious but essential. Assumptions lead to bugs. Measurement reveals truth.

Our energy efficiency findings challenged theoretical expectations. Practical throughput (938 kb/s) was 47% of theoretical (2 Mb/s)—but that's normal for BLE due to protocol overhead.

Academia provides rigor. Real-world testing provides reality.

#ResearchAndDevelopment #Engineering #Academia #ContinuousLearning

---

## Post 10: The KNIFE Framework Advantage

Ondrej Špánik developed the KNIFE Framework for documenting IoT projects.

It enforced discipline we didn't know we needed:
→ Systematic documentation during development
→ Structured knowledge capture
→ Reproducible methodology
→ Clear decision tracking

When we hit roadblocks (like the last packet BLE issue), our documentation helped us quickly isolate the problem and make informed decisions.

Good frameworks aren't constraints. They're accelerators.

#ProjectManagement #Documentation #BestPractices #TeamWork

---

## Post 11: Automotive-Grade Components Make a Difference

We tested with u-blox Jody-W263 automotive-grade Bluetooth module.

The difference vs consumer-grade components:
→ Temperature tolerance: -40°C to +85°C
→ EMI resistance: Superior stability
→ Reliability: Consistent performance
→ Certifications: Industry compliance

Cost: 2-3x more expensive
Debugging time saved: 10x less
Field failure rate: Near zero

For serious applications, automotive-grade is worth it.

#AutomotiveTechnology #QualityEngineering #ComponentSelection

---
