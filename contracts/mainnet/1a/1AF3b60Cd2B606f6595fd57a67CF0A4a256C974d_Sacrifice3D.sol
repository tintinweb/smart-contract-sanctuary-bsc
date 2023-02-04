/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.4.26;

interface HourglassInterface {
    function deposit(address _playerAddress) payable external returns(uint256);
    function harvest() external;
    function myDividends(bool _includeReferralBonus) external view returns(uint256);
}

contract Sacrifice3D {
    
    struct Stage {
        uint8 numberOfPlayers;
        uint256 blocknumber;
        bool finalized;
        mapping (uint8 => address) slotXplayer;
        mapping (address => bool) players;
    }
    
    HourglassInterface public hourglass;

    address public pricefloorAddress;

    uint8 public maxPlayers;

    uint256 public houseFee;
    uint256 public entryCost;
    uint256 public userPrize;

    uint256 public totalStages;
    uint256 public totalCompletedStages;
    
    mapping(address => uint256) private lastRoundEntered;
    mapping(address => uint256) private playerVault;
    mapping(uint256 => Stage) private stages;
    
    event SacrificeOffered(address indexed player);
    event SacrificeChosen(address indexed sarifice);
    event EarningsWithdrawn(address indexed player, uint256 indexed amount);
    event StageInvalidated(uint256 indexed stage);
    
    modifier hasEarnings() {
        require(playerVault[msg.sender] > 0);
        _;
    }
    
    modifier prepareStage() {
        if(stages[totalStages - 1].numberOfPlayers == maxPlayers) {
           stages[totalStages] = Stage(0, 0, false);
           totalStages++;
        }
        _;
    }
    
    modifier isNewToStage() {
        require(stages[totalStages - 1].players[msg.sender] == false);
        _;
    }
    
    constructor(address _hourglassAddress, address _pricefloorAddress) public {
        hourglass = HourglassInterface(_hourglassAddress);
        
        pricefloorAddress = _pricefloorAddress;
        
        stages[totalStages] = Stage(0, 0, false);

        maxPlayers = 5;

        entryCost = 0.1 ether;
        houseFee = 0.02 ether;
        userPrize = 0.12 ether;

        totalStages++;
    }
    
    function() external payable {}
    
    function deposit(bool _useVault) external payable prepareStage isNewToStage {
        if (_useVault) {
            require(playerVault[msg.sender] >= entryCost);
            playerVault[msg.sender] -= entryCost;
        } else {
            require(msg.value == entryCost);
        }

        acceptOffer();
        tryFinalizeStage();
    }
    
    function withdraw() external hasEarnings {
        tryFinalizeStage();
        
        uint256 amount = playerVault[msg.sender];
        playerVault[msg.sender] = 0;
        
        emit EarningsWithdrawn(msg.sender, amount); 
        
        msg.sender.transfer(amount);
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////
    
    function myEarnings() external view hasEarnings returns(uint256) {
        return playerVault[msg.sender];
    }
    
    function currentPlayers() external view returns(uint256) {
        return stages[totalStages - 1].numberOfPlayers;
    }

    function lastRoundPlayedOf(address _addr) external view returns (uint256) {
        return (lastRoundEntered[_addr]);
    }

    function getCurrentRoundPlayers() external view returns (address[] memory players) {
        Stage storage currentStage = stages[totalStages - 1];
        players = new address[](currentStage.numberOfPlayers);
        for (uint8 i = 0; i < currentStage.numberOfPlayers; i++) {
            players[i] = currentStage.slotXplayer[i];
        }
    }

    //////////////////////////////////
    // PRIVATE & INTERNAL FUNCTIONS //
    //////////////////////////////////
    
    function acceptOffer() private {
        Stage storage currentStage = stages[totalStages - 1];
        
        assert(currentStage.numberOfPlayers < maxPlayers);
        
        address player = msg.sender;
        
        //add player to current stage
        currentStage.slotXplayer[currentStage.numberOfPlayers] = player;
        currentStage.numberOfPlayers++;
        currentStage.players[player] = true;
        
        emit SacrificeOffered(player);
        
        //add blocknumber to current stage when the last player is added
        if(currentStage.numberOfPlayers == maxPlayers) {
            currentStage.blocknumber = block.number;
        }
    }
    
    function tryFinalizeStage() private {
        assert(totalStages >= totalCompletedStages);
        
        //there are no stages to finalize
        if(totalStages == totalCompletedStages) {return;}
        
        Stage storage stageToFinalize = stages[totalCompletedStages];
        
        assert(!stageToFinalize.finalized);
        
        //stage is not ready to be finalized
        if(stageToFinalize.numberOfPlayers < maxPlayers) {return;}
        
        assert(stageToFinalize.blocknumber != 0);
        
        //check if blockhash can be determined
        if(block.number - 256 <= stageToFinalize.blocknumber) {
            //blocknumber of stage can not be equal to current block number -> blockhash() won't work
            if(block.number == stageToFinalize.blocknumber) {return;}
                
            //determine sacrifice
            uint8 sacrificeSlot = uint8(blockhash(stageToFinalize.blocknumber)) % maxPlayers;
            address sacrifice = stageToFinalize.slotXplayer[sacrificeSlot];
            
            emit SacrificeChosen(sacrifice);
            
            //allocate winnings to survivors
            allocateSurvivorWinnings(sacrifice);
            
            //allocate dividends to sacrifice if existing
            uint256 dividends = hourglass.myDividends(true);
            if(dividends > 0) {
                hourglass.harvest();
                playerVault[sacrifice] += dividends;
            }

            hourglass.deposit.value(houseFee)(pricefloorAddress);
        } else {
            invalidateStage(totalCompletedStages);
            
            emit StageInvalidated(totalCompletedStages);
        }
        //finalize stage
        stageToFinalize.finalized = true;
        totalCompletedStages++;
    }
    
    function allocateSurvivorWinnings(address sacrifice) private {
        for (uint8 i = 0; i < maxPlayers; i++) {
            address survivor = stages[totalCompletedStages].slotXplayer[i];
            if(survivor != sacrifice) {
                playerVault[survivor] += userPrize;
            }
        }
    }
    
    function invalidateStage(uint256 stageIndex) private {
        Stage storage stageToInvalidate = stages[stageIndex];
        
        for (uint8 i = 0; i < maxPlayers; i++) {
            address player = stageToInvalidate.slotXplayer[i];
            playerVault[player] += entryCost;
        }
    }
}