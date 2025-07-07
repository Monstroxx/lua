# Installation Guide - Grow a Garden Automation

## Quick Start (ONE FILE SOLUTION)

**Final Automation System (All-in-One):**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/finalLoader.lua"))()
```

✅ **Fixes ALL nil-value errors**  
✅ **No UI loading issues**  
✅ **No sync problems**  
✅ **Single file solution**  
✅ **Complete automation features**

**Features:**
- 🌱 Auto farming (planting, collecting)
- 🛒 Auto shopping (seeds, gear, eggs)
- 🐾 Pet management
- 📊 Real-time status monitoring
- 💬 Chat commands
- 🆘 Emergency stop (Ctrl+Alt+X)

## Alternative Loading (Manual)

If you prefer to load components separately:

1. **Load Backend System:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/completeAutomationSystem.lua"))()
```

2. **Load UI System:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/advancedAutomationUI.lua"))()
```

3. **Load Bridge System:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/lua/main/grow-a-garden-automation/automationBridge.lua"))()
```

## Chat Commands

After loading, you can use these commands:

- `/autostart` - Start automation
- `/autostop` - Stop automation
- `/autostatus` - Show current status
- `/plant` - Manual plant seeds
- `/collect` - Manual collect plants
- `/buy` - Manual buy seeds
- `/pets` - Manual pet management
- `/trade` - Accept incoming trade
- `/tradewith [playername]` - Trade with specific player
- `/help` - Show all commands

## Emergency Stop

**Ctrl+Alt+X** - Emergency stop all automation

## Features

### 🌱 **Farming System**
- ✅ Auto planting with seed selection
- ✅ Auto collecting with proximity prompts
- ✅ Smart teleportation to plants
- ✅ Watering can automation
- ✅ Priority-based rare item collection

### 🛒 **Shopping System**
- ✅ Auto buy seeds with UI navigation
- ✅ Auto buy gear and tools
- ✅ Auto buy pet eggs
- ✅ Stock management with safety limits
- ✅ Smart money management

### 🐾 **Pet Management**
- ✅ Auto equip best pets
- ✅ Auto feed pets
- ✅ Auto hatch eggs
- ✅ Pet UI navigation
- ✅ Smart pet value calculation

### 🎯 **Trading System**
- ✅ Auto accept trades
- ✅ Target player trading
- ✅ Smart teleportation to players
- ✅ Item equipping for trades
- ✅ Proximity prompt automation

### 📊 **Dashboard & Monitoring**
- ✅ Real-time status updates
- ✅ Resource monitoring
- ✅ Performance metrics
- ✅ Webhook notifications
- ✅ Health check system

### ⚡ **Performance Features**
- ✅ Graphics optimization
- ✅ Animation disabling
- ✅ Memory optimization
- ✅ FPS limiting
- ✅ Low memory mode

## Configuration

The system includes comprehensive configuration options:

- **Auto Buy Settings**: Seeds, gear, eggs with spending limits
- **Farming Settings**: Seed selection, intervals, watering
- **Pet Settings**: Auto equip, feed, hatch with preferences
- **Trading Settings**: Target players, item filters, safety limits
- **Performance Settings**: Graphics, animations, memory optimization

## Requirements

- ✅ Roblox executor with HttpGet support
- ✅ Working internet connection
- ✅ Grow a Garden game access
- ✅ Basic understanding of Roblox scripting (optional)

## Troubleshooting

### Common Issues:

1. **"Backend initialization timed out - Config not available"** ✅ FIXED
   - **Solution**: Use simpleLoader.lua instead of mainLoader.lua
   - **Root cause**: Timing issue between components fixed in backend
   - **Alternative**: Run debugScript.lua first, then mainLoader.lua

2. **"Backend not loading"**
   - Check internet connection
   - Verify executor supports HttpGet
   - Try simpleLoader.lua for better error handling

3. **"UI not responding"**
   - Use `/status` to check connection
   - Try simpleLoader.lua for minimal setup
   - Check console for specific error messages

4. **"Automation not working"**
   - Verify you're in Grow a Garden game
   - Use `/start` to enable automation
   - Use `/status` to check current state

5. **"Trading not working"**
   - Make sure target player is online
   - Check if you have items to trade
   - Verify trading is enabled in settings

### Error Recovery:

- **Emergency Stop**: Ctrl+Alt+X
- **Restart System**: Reload mainLoader.lua
- **Reset Settings**: Clear _G.AutomationSystem and reload

## Support

For issues or questions:
- Create an issue on the GitHub repository
- Check the console for error messages
- Use `/help` command for available options

## Safety Notes

- ⚠️ Always keep minimum money reserves
- ⚠️ Don't leave automation running unattended for extended periods
- ⚠️ Review trading settings before enabling auto-accept
- ⚠️ Use emergency stop if needed