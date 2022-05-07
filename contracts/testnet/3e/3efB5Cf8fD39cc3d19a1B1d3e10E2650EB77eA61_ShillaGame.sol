// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IShillaVault.sol";
import "./UintStrings.sol";
import "./IShilla.sol";
import "./ERC721Leasable.sol";

interface IShillaGameArtwork {
    function tokenURI(uint256 gameId) external view returns(string memory);
}

contract ShillaGame is ERC721Leasable, Ownable {
    using SafeERC20 for IShilla;
    using UintStrings for uint256;

    struct GameSession {
        bool awaitingPlayers;
        uint256 bank;
        uint256 startBlock;
        uint256 endBlock;
        address primaryWinner;
        address secondaryWinner;
        uint256 primaryWinnerPrize;
        uint256 secondaryWinnerPrize;
        uint256 ownerFee;
        uint256 vaultFee;
        address[] players;
        uint256 lastVaultPortion;
        uint256 lastOwnerPortion;
        uint8 primaryWinnerPercentage;
        uint8 secondaryWinnerPercentage;
        uint8 ownerPercentage;
        uint8 vaultPercentage;
        uint256 totalSessions;
        uint256 totalProfits;
        uint256 blockTime;
        uint256 playBlock;
        uint256 lastSecWinnerIndex;
    }
    struct Game {
        uint256 id;
        uint256 bank;
        uint256 entryPrice;
        uint256 countDownDuration;
        uint8 primaryWinnerPercentage;
        uint8 secondaryWinnerPercentage;
        uint8 ownerPercentage;
        uint256 totalSessions;
        uint256 totalPlayers;
        uint256 totalProfits;
        GameSession session;
    }

    mapping(uint256 => Game) private games;
    uint256 public lastGameId;
    event GameMinted(
        uint256 indexed gameId, 
        address indexed owner, 
        uint256 entryPrice, 
        uint256 countDownDuration, 
        uint256 ownerPercentage, 
        uint256 primaryWinnerPercentage, 
        uint256 secondaryWinnerPercentage
    );
    event GameEnded(
        uint256 indexed gameId, 
        address indexed primaryWinner, 
        address indexed secondaryWinner, 
        uint256 sessionId, 
        uint256 primaryWinnerPrize, 
        uint256 secondaryWinnerPrize,
        uint256 totalPlayers
    );
    event GameUpdated(
        uint256 indexed gameId, 
        uint256 entryPrice, 
        uint256 countDownDuration, 
        uint256 ownerPercentage, 
        uint256 primaryWinnerPercentage, 
        uint256 secondaryWinnerPercentage
    );
    event Played(
        uint256 indexed gameId, 
        address indexed player, 
        uint256 playBlock, 
        uint256 latestEndBlock, 
        uint256 latestGameBank, 
        uint256 playPos
    );
    event PrizeClaimed(
        uint256 indexed gameId, 
        address indexed winner, 
        uint8 indexed winnerType, 
        uint256 amount, 
        uint256 sessionId
    );
    event PrizeSent(
        uint256 indexed gameId, 
        address indexed winner, 
        uint8 indexed winnerType, 
        uint256 amount, 
        uint256 sessionId
    );
    event CurrentWins(
        uint256 indexed gameId, 
        address indexed primaryWinner, 
        address indexed secondaryWinner, 
        uint256 primaryWinnerPrize, 
        uint256 secondaryWinnerPrize
    );
    event GameFunded(address indexed funder, uint256 indexed gameId, uint256 activeSessionId, uint256 latestGameBank, bool fundedToSession);
    event HouseFeeClaimed(uint256 indexed gameId, address indexed owner, uint256 sessionId, uint256 amountPaid, uint256 amountsPending);
    event HouseFeeSent(uint256 indexed gameId, address indexed owner, uint256 sessionId, uint256 amountPaid, uint256 amountsPending);
    event GameVaultFeeSent(uint256 indexed gameId, uint256 amount, uint256 sessionId);
    event GameStarted(uint256 indexed gameId, uint256 indexed sessionId, uint256 gameBank, uint256 startBlock);
    event GameCanceled(uint256 indexed gameId, uint256 indexed sessionId, uint256 indexed prevSessionId, uint256 withdrawal);

    uint32 constant MIN_DURATION = 9 seconds;
    uint32 constant MAX_DURATION = 86400 seconds;
    uint8 constant DEFAULT_DURATION = 120 seconds;
    uint8 constant DEFAULT_PRIMARY_WINNER_PERCENTAGE = 65;
    uint8 constant DEFAULT_SECONDARY_WINNER_PERCENTAGE = 20;
    uint8 constant DEFAULT_CREATOR_PERCENTAGE = 15;
    uint8 constant SEC_PER = 30;

    uint256 public currentGamePlays;


    IShilla public token;
    IShillaVault public shillaVault;
    IShillaGameArtwork shillaGameArtwork;
    uint8 public tokenDecimals;
    string public baseURIextended = "https://shillaplay.com/game/?id=";
    uint8 public vaultPercentage = 2;
    uint8 public blockTime = 3;
    uint8 public ownerPortionNowPercentage = 80;
    uint8 public ownerPortionWhenOverPercentage = 20;
    uint256 public totalGlobalSessions;
    uint256 public totalGlobalPlayers;
    uint256 public totalGlobalProfits;
    uint256 public totalGlobalLastSessionPlayers;
    uint256 public totalGlobalLastSessionProfits;
    uint256 public tvl;
    uint256 public minGameBank;
    mapping(address => uint256[]) private gamesOf;

    modifier onlyGameOwner(uint256 gameId) {
        require(msg.sender == ERC721Leasable.ownerOf(gameId), "1");
        _;
    }

    constructor(address _token, address _shillaVault, uint8 _tokenDecimals) ERC721Leasable("Shilla Game", "SHILLAGAME") {
        token = IShilla(_token);
        shillaVault = IShillaVault(_shillaVault);
        tokenDecimals = _tokenDecimals;
        minGameBank = 1 * 10**_tokenDecimals;
    }
    
    function mint(
        uint256 entryPrice, 
        uint256 countDownDuration, 
        uint8 ownerPercentage, 
        uint8 primaryWinnerPercentage, 
        uint8 secondaryWinnerPercentage
    ) external returns (uint256 id) {
        require(countDownDuration >= MIN_DURATION && countDownDuration <= MAX_DURATION, "4");
        require(ownerPercentage > 0, "p1");
        require(primaryWinnerPercentage > 0, "p2");
        require(secondaryWinnerPercentage > 0, "p3");
        require((ownerPercentage + primaryWinnerPercentage + secondaryWinnerPercentage) == 100, "ip");

        id = ++lastGameId;
        games[id].id = id;
        games[id].entryPrice = entryPrice;

        require(games[id].entryPrice >= minGameBank, "sh");

        games[id].countDownDuration = countDownDuration;
        games[id].ownerPercentage = ownerPercentage;
        games[id].primaryWinnerPercentage = primaryWinnerPercentage;
        games[id].secondaryWinnerPercentage = secondaryWinnerPercentage;

        gamesOf[msg.sender].push(id);
        
        _mint(msg.sender, id);
        emit GameMinted(
            id, 
            msg.sender, 
            games[id].entryPrice, 
            countDownDuration, 
            ownerPercentage, 
            primaryWinnerPercentage, 
            secondaryWinnerPercentage
        );
    }
    
    function lastGameMintOf(address account) external view returns (uint256) {
        if(gamesOf[account].length > 0) return gamesOf[account][gamesOf[account].length - 1];
        return 0;
    }
    
    function updateGame(
        uint256 gameId, 
        uint256 entryPrice, 
        uint8 countDownDuration, 
        uint8 ownerPercentage, 
        uint8 primaryWinnerPercentage, 
        uint8 secondaryWinnerPercentage
    ) external onlyGameOwner(gameId) {
        require(_exists(gameId), "2");
        require(!ShillaGame.gameIsActive(gameId) && !ShillaGame.gameAwaitsPlayers(gameId), "3");
        if(entryPrice > 0) {
            games[gameId].entryPrice = entryPrice;
            require(games[gameId].entryPrice >= minGameBank, "sh");
        }
        if(countDownDuration > 0) {
            require(countDownDuration >= MIN_DURATION && countDownDuration <= MAX_DURATION, "4");
            games[gameId].countDownDuration = countDownDuration;
        }
        if(ownerPercentage > 0) {
            games[gameId].ownerPercentage = ownerPercentage;
        }
        if(primaryWinnerPercentage > 0) {
            games[gameId].primaryWinnerPercentage = primaryWinnerPercentage;
        }
        if(secondaryWinnerPercentage > 0) {
            games[gameId].secondaryWinnerPercentage = secondaryWinnerPercentage;
        }
        require((games[gameId].ownerPercentage + games[gameId].primaryWinnerPercentage + games[gameId].secondaryWinnerPercentage) == 100, "ip2");

        emit GameUpdated(gameId, games[gameId].entryPrice, games[gameId].countDownDuration, games[gameId].ownerPercentage, games[gameId].primaryWinnerPercentage, games[gameId].secondaryWinnerPercentage);
    }
    
    function diburseGameBank(uint256 gameId) external {
         _diburseGameBank(gameId);
    }
    
    function startSession(uint256 gameId, uint256 gameBankIncrement, uint256 startSecondsFromNow) external onlyGameOwner(gameId) {
        _diburseGameBank(gameId);
        if(gameBankIncrement > 0) {
            token.safeTransferFrom(msg.sender, address(this), gameBankIncrement);
            games[gameId].bank = games[gameId].bank + gameBankIncrement;
            tvl = tvl + gameBankIncrement;
        }
        require(games[gameId].bank >= minGameBank, "5");
        games[gameId].session.bank = games[gameId].bank;
        games[gameId].bank = 0;
        games[gameId].session.startBlock = block.number + (startSecondsFromNow/blockTime);
        games[gameId].session.blockTime = blockTime;
        games[gameId].session.awaitingPlayers = true;
        games[gameId].session.primaryWinnerPercentage = games[gameId].primaryWinnerPercentage;
        games[gameId].session.secondaryWinnerPercentage = games[gameId].secondaryWinnerPercentage;
        games[gameId].session.ownerPercentage = games[gameId].ownerPercentage;
        games[gameId].session.vaultPercentage = vaultPercentage;
        games[gameId].totalSessions++;
        totalGlobalSessions++;
        emit GameStarted(gameId, games[gameId].totalSessions, games[gameId].session.bank, games[gameId].session.startBlock);
        _shareBank(gameId);
    }
    
    function cancelSession(uint256 gameId, bool withdraw) external onlyGameOwner(gameId) {
        require(!ShillaGame.gameIsActive(gameId), "6");
        require(ShillaGame.gameAwaitsPlayers(gameId), "7");
        if(withdraw) {
            token.safeTransfer(msg.sender, games[gameId].session.bank);
            emit GameCanceled(gameId, games[gameId].totalSessions, games[gameId].totalSessions - 1, games[gameId].session.bank);
            tvl = tvl - games[gameId].session.bank;
            games[gameId].session.bank = 0;
        } else {
            games[gameId].bank += games[gameId].session.bank;
            games[gameId].session.bank = 0;
            emit GameCanceled(gameId, games[gameId].totalSessions, games[gameId].totalSessions - 1, 0);
        }
        games[gameId].session.startBlock = 0;
        games[gameId].session.awaitingPlayers = false;
        games[gameId].totalSessions--;
        totalGlobalSessions--;
        games[gameId].session.primaryWinnerPrize = 0;
    }
    
    function fundGame(uint256 gameId, uint256 amount) external {
        require(_exists(gameId), "8");
        token.safeTransferFrom(msg.sender, address(this), amount);
        tvl = tvl + amount;
        if(ShillaGame.gameAwaitsPlayers(gameId) || ShillaGame.gameIsActive(gameId)) {
            games[gameId].session.bank = games[gameId].session.bank + amount;
            emit GameFunded(msg.sender, gameId, games[gameId].totalSessions, games[gameId].session.bank, true);
            _shareBank(gameId);

        } else {
            games[gameId].bank = games[gameId].bank + amount;
            emit GameFunded(msg.sender, gameId, 0, games[gameId].bank, false);
        }
    }
    
    function play(uint256 gameId) external {
        require(_exists(gameId), "9");
        games[gameId].session.primaryWinner = msg.sender;
        if(ShillaGame.gameAwaitsPlayers(gameId)) {
            //require game is not upcoming
            require(games[gameId].session.startBlock <= block.number, "10");
            games[gameId].session.awaitingPlayers = false;
            totalGlobalLastSessionPlayers = (totalGlobalLastSessionPlayers - games[gameId].session.players.length) + 1;
            totalGlobalLastSessionProfits = totalGlobalLastSessionProfits - games[gameId].session.totalProfits;
            
            delete games[gameId].session.players;
            games[gameId].session.totalProfits = 0;
            games[gameId].session.players.push(msg.sender);

        } else {
            //ToDo
            require(ShillaGame.gameIsActive(gameId), "11");
            totalGlobalLastSessionPlayers = totalGlobalLastSessionPlayers + 1;
            games[gameId].session.players.push(msg.sender);
            games[gameId].session.secondaryWinner = _chooseSecondaryWinner(gameId);
        }
        games[gameId].totalPlayers++;
        totalGlobalPlayers++;
        //ToDo
        games[gameId].session.endBlock = block.number + (games[gameId].countDownDuration/games[gameId].session.blockTime);
        games[gameId].session.playBlock = block.number;
        token.safeTransferFrom(msg.sender, address(this), games[gameId].entryPrice);
        tvl = tvl + games[gameId].entryPrice;
        games[gameId].session.bank = games[gameId].session.bank + games[gameId].entryPrice;

        _shareBank(gameId);

        emit Played(gameId, msg.sender, block.number, games[gameId].session.endBlock, games[gameId].session.bank, games[gameId].session.players.length);
        
        currentGamePlays += 1;
    }
    
    function burn(uint256 gameId) external {
        _burnGame(gameId);
        _burn(gameId);
    }
    
    function _setVault(IShillaVault _shillaVault) external onlyOwner {
        shillaVault = _shillaVault;
    }
    
    function _setShillaGameArtwork(IShillaGameArtwork _shillaGameArtwork) external onlyOwner {
        shillaGameArtwork = _shillaGameArtwork;
    }
    
    function _setBaseURI(string memory baseURI_) external onlyOwner() {
        baseURIextended = baseURI_;
    }
    
    function _setVaultPercentage(uint8 _vaultPercentage) external onlyOwner {
        vaultPercentage = _vaultPercentage;
    }
    
    function _setBlockTime(uint8 _blockTime) external onlyOwner {
        blockTime = _blockTime;
    }

    function _setMinGameBank(uint256 amountNoDecimals) external onlyOwner {
        minGameBank = amountNoDecimals * 10**tokenDecimals;
    }
    
    function gameInfo(uint256 gameId) external view returns(
        address owner,
        uint256 entryPrice,
        uint256 countDownDuration,
        uint8 primaryWinnerPercentage,
        uint8 secondaryWinnerPercentage,
        uint8 ownerPercentage,
        uint256 totalSessions,
        uint256 totalPlayers,
        uint256 totalProfits,
        uint256 bank
    ) {
        owner = ERC721Leasable.ownerOf(gameId);
        entryPrice = games[gameId].entryPrice;
        countDownDuration = games[gameId].countDownDuration;
        primaryWinnerPercentage = games[gameId].primaryWinnerPercentage;
        secondaryWinnerPercentage = games[gameId].secondaryWinnerPercentage;
        ownerPercentage = games[gameId].ownerPercentage;
        totalSessions = games[gameId].totalSessions;
        totalPlayers = games[gameId].totalPlayers;
        totalProfits = games[gameId].totalProfits;
        bank = games[gameId].bank;
    }

    function gameSessionInfo(uint256 gameId) external view returns(
        uint256 startBlock,
        uint256 endBlock,
        uint256 playBlock,
        uint256 primaryWinnerPrize, 
        uint256 secondaryWinnerPrize,
        uint256 ownerPrize,
        uint256 vaultPrize,
        uint256 bank,
        uint256 totalPlayers,
        bool awaitingPlayers,
        address primaryWinner, 
        address secondaryWinner
    ) {
        startBlock = games[gameId].session.startBlock;
        endBlock = games[gameId].session.endBlock;
        playBlock = games[gameId].session.playBlock;
        primaryWinnerPrize = games[gameId].session.primaryWinnerPrize;
        secondaryWinnerPrize = games[gameId].session.secondaryWinnerPrize;
        ownerPrize = games[gameId].session.lastOwnerPortion;
        vaultPrize = games[gameId].session.lastVaultPortion;
        bank = games[gameId].session.bank;
        totalPlayers = games[gameId].session.awaitingPlayers? 0 : games[gameId].session.players.length;
        awaitingPlayers = games[gameId].session.awaitingPlayers;
        primaryWinner = games[gameId].session.primaryWinner;
        secondaryWinner = games[gameId].session.secondaryWinner;
    }
    
    function tokenURI(uint256 gameId) override public view returns (string memory) {
        require(_exists(gameId), "21");
        if(address(shillaGameArtwork) == address(0)) {
            return string(abi.encodePacked(baseURIextended,gameId.toString())); 

        } else {
            return shillaGameArtwork.tokenURI(gameId);
        }
    }
    
    function _shareBank(uint256 gameId) private {
        (uint256 vaultPortion, uint256 ownerPortion, uint256 primaryWinnerPortion, uint256 secondaryWinnerPortion) 
        = _splitBank(gameId);

        if(vaultPortion > 0) {
            uint256 portion = vaultPortion - games[gameId].session.lastVaultPortion;
            games[gameId].session.lastVaultPortion = vaultPortion;
            if(portion > 0) {
                tvl = tvl - portion;
                token.approve(address(shillaVault), portion);
                shillaVault.diburseProfits(portion);
                emit GameVaultFeeSent(gameId, portion, games[gameId].totalSessions);
            }
        }

        if(ownerPortion > 0) {
            uint256 portion = ownerPortion - games[gameId].session.lastOwnerPortion;
            games[gameId].session.lastOwnerPortion = ownerPortion;
            
            uint256 ownerPortionNow; uint256 ownerPortionWhenOver;
            if(portion > 0) {
                ownerPortionNow = (portion * ownerPortionNowPercentage) / 100;
                ownerPortionWhenOver = portion - ownerPortionNow;
            }

            if(ownerPortionNow > 0 || ownerPortionWhenOver > 0) {
                if(ownerPortionNow > 0) {
                    tvl = tvl - ownerPortionNow;
                    token.safeTransfer(ERC721Leasable.ownerOf(gameId), ownerPortionNow);
                    
                }
                if(ownerPortionWhenOver > 0) {
                    games[gameId].session.ownerFee = games[gameId].session.ownerFee + ownerPortionWhenOver;
                }

                emit HouseFeeSent(gameId, ERC721Leasable.ownerOf(gameId), games[gameId].totalSessions, ownerPortionNow, games[gameId].session.ownerFee);
            }

            games[gameId].session.totalProfits = games[gameId].session.totalProfits + portion;
            games[gameId].totalProfits = games[gameId].totalProfits + portion;
            totalGlobalProfits = totalGlobalProfits + portion;
            totalGlobalLastSessionProfits = totalGlobalLastSessionProfits + portion;
        }
        
        games[gameId].session.primaryWinnerPrize = primaryWinnerPortion;
        if(secondaryWinnerPortion > 0) {
            games[gameId].session.secondaryWinnerPrize = secondaryWinnerPortion;
        }
        emit CurrentWins(gameId, games[gameId].session.primaryWinner, games[gameId].session.secondaryWinner, games[gameId].session.primaryWinnerPrize, games[gameId].session.secondaryWinnerPrize);
    }
    
    function _burnGame(uint256 gameId) private {
        //handle game burning here
        _diburseGameBank(gameId);
        if(games[gameId].bank > 0) {
            token.safeTransfer(ERC721Leasable.ownerOf(gameId), games[gameId].bank);
            tvl = tvl - games[gameId].bank;
        }
        
        for (uint256 i = 0; i < gamesOf[msg.sender].length; i++) {
            if (gamesOf[msg.sender][i] == gameId) {
                gamesOf[msg.sender][i] = gamesOf[msg.sender][gamesOf[msg.sender].length - 1];
                gamesOf[msg.sender].pop();
                break;
            }
        }
    }
    
    function _diburseGameBank(uint256 gameId) private {
        require(!ShillaGame.gameIsActive(gameId) && !ShillaGame.gameAwaitsPlayers(gameId), "22");
        //distribute each prizes and fees

        if(games[gameId].session.primaryWinnerPrize > 0) {
            address primaryWinner; address secondaryWinner;

            token.safeTransfer(games[gameId].session.primaryWinner, games[gameId].session.primaryWinnerPrize);
            
            tvl = tvl - games[gameId].session.primaryWinnerPrize;

            uint256 prize1 = games[gameId].session.primaryWinnerPrize;
            uint256 prize2;
            primaryWinner = games[gameId].session.primaryWinner;
            if(msg.sender == games[gameId].session.primaryWinner) {
                emit PrizeClaimed(gameId, msg.sender, 0, games[gameId].session.primaryWinnerPrize, games[gameId].totalSessions);

            } else {
                emit PrizeSent(gameId, games[gameId].session.primaryWinner, 0, games[gameId].session.primaryWinnerPrize, games[gameId].totalSessions);
            }
            games[gameId].session.primaryWinnerPrize = 0;
            games[gameId].session.primaryWinner = address(0);

            if(games[gameId].session.secondaryWinnerPrize > 0) {
                token.safeTransfer(games[gameId].session.secondaryWinner, games[gameId].session.secondaryWinnerPrize);
                
                tvl = tvl - games[gameId].session.secondaryWinnerPrize;

                prize2 = games[gameId].session.secondaryWinnerPrize;
                secondaryWinner = games[gameId].session.secondaryWinner;
                if(msg.sender == games[gameId].session.secondaryWinner) {
                    emit PrizeClaimed(gameId, msg.sender, 1, games[gameId].session.secondaryWinnerPrize, games[gameId].totalSessions);

                } else {
                    emit PrizeSent(gameId, games[gameId].session.secondaryWinner, 1, games[gameId].session.secondaryWinnerPrize, games[gameId].totalSessions);
                }
                games[gameId].session.secondaryWinnerPrize = 0;
                games[gameId].session.secondaryWinner = address(0);
            }

            if(games[gameId].session.ownerFee > 0) {
                uint256 fee = games[gameId].session.ownerFee;
                tvl = tvl - fee;
                games[gameId].session.ownerFee = 0;

                token.safeTransfer(ERC721Leasable.ownerOf(gameId), fee);

                if(msg.sender == ERC721Leasable.ownerOf(gameId)) {
                    emit HouseFeeClaimed(gameId, msg.sender, games[gameId].totalSessions, fee, 0);

                } else {
                    emit HouseFeeSent(gameId, msg.sender, games[gameId].totalSessions, fee, 0);
                }
            }

            games[gameId].session.startBlock = 0;
            games[gameId].session.playBlock = 0;
            games[gameId].session.endBlock = 0;
            games[gameId].session.bank = 0;
            games[gameId].session.lastVaultPortion = 0;
            games[gameId].session.lastOwnerPortion = 0;

            currentGamePlays -= games[gameId].session.players.length;

            emit GameEnded(gameId, primaryWinner, secondaryWinner, games[gameId].totalSessions, prize1, prize2, games[gameId].session.players.length);
        }
    }

    function _chooseSecondaryWinner(uint256 gameId) private returns(address) {
        if(games[gameId].session.players.length == 2) {
            games[gameId].session.lastSecWinnerIndex = 0;

        } else {
            uint256 chairs = ((SEC_PER * games[gameId].session.players.length) / 100) + 1;
            games[gameId].session.lastSecWinnerIndex = (games[gameId].session.lastSecWinnerIndex + 1) % chairs;
        }
        
        return games[gameId].session.players[games[gameId].session.lastSecWinnerIndex];
    }
    
    //The winners must get their investments back(entryPrice) before calculating their share of the bank.
    function _splitBank(uint256 gameId) private view returns(uint256 vaultPortion, uint256 ownerPortion, uint256 primaryWinnerPortion, uint256 secondaryWinnerPortion) {
        if(games[gameId].session.awaitingPlayers) {
            primaryWinnerPortion = games[gameId].session.bank - ((games[gameId].session.bank * games[gameId].session.vaultPercentage) / 100);

        } else if(games[gameId].session.players.length == 1) {
            //Only the vault and the only player share the bank
            //remove player investment
            uint256 toShare = games[gameId].session.bank - games[gameId].entryPrice;
            vaultPortion = (toShare * games[gameId].session.vaultPercentage) / 100;
            primaryWinnerPortion = games[gameId].session.bank - vaultPortion;

        } else if(games[gameId].session.players.length == 2) {
            //Only the vault, and the only two players share the bank
            //remove player investments
            uint256 toShare = games[gameId].session.bank - (games[gameId].entryPrice * 2);
            vaultPortion = (toShare * games[gameId].session.vaultPercentage) / 100;
            toShare = toShare - vaultPortion;
            primaryWinnerPortion = games[gameId].entryPrice + 
            (
                (toShare * games[gameId].session.primaryWinnerPercentage) / 
                (games[gameId].session.primaryWinnerPercentage + games[gameId].session.secondaryWinnerPercentage)
            );
            secondaryWinnerPortion = games[gameId].session.bank - (vaultPortion + primaryWinnerPortion);

        } else {
            //the vault, two players, and the game owner share the bank
            //remove player investments
            uint256 toShare = games[gameId].session.bank - (games[gameId].entryPrice * 2);
            vaultPortion = (toShare * games[gameId].session.vaultPercentage) / 100;
            toShare = toShare - vaultPortion;
            ownerPortion = (toShare * games[gameId].session.ownerPercentage) / 100;
            primaryWinnerPortion = games[gameId].entryPrice + ((toShare * games[gameId].session.primaryWinnerPercentage) / 100);
            secondaryWinnerPortion = games[gameId].session.bank - (vaultPortion + ownerPortion + primaryWinnerPortion);
        }
    }
    
    function gameAwaitsPlayers(uint256 gameId) public view returns (bool) {
        return games[gameId].session.awaitingPlayers;
    }
    
    function gameIsActive(uint256 gameId) public view returns (bool) {
        return games[gameId].session.endBlock > block.number;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library UintStrings {
    bytes16 internal constant ALPHABET = '0123456789abcdef';

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShillaVault {
    function diburseProfits(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IShilla is IERC20 {
    function decimals() external view returns (uint8);
    function burn(uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Leasable is ERC721 {
    // Mapping from account to a map of token ID to lease request duration
    mapping(address => mapping(uint256 => uint256)) private _durations;
    // Mapping owner address to token lease count count
    mapping(address => uint256) private _leaseOf;
    // Mapping from token ID to lease
    mapping(uint256 => Lease) private _leaseFor;

    struct Lease {
        address from;
        address to;
        uint256 expiry;
    }

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    }

    modifier claimLease(address claimer, uint256 tokenId) {
        //If the token is a lease, both the leaser and the leasee must be sent to the block below
        //for scrutiny
        if(_leaseFor[tokenId].from != address(0)) {
            //Then the claimer has to be the leaser, and the lease expiry time must has elapsed.
            //This means since a leasee/claimer won't be the leaser/_leaseFor[tokenId].from,
            //The leasee can't transfer or approve a leased token.
            //Also, the leaser can't transfer or approve either until the lease has expired
            require(claimer == _leaseFor[tokenId].from && _leaseFor[tokenId].expiry <= block.timestamp, "ERC721Leasable: Lease unclaimable");
            _transfer(_leaseFor[tokenId].to, _leaseFor[tokenId].from, tokenId);
            _leaseFor[tokenId].from = address(0);
            _leaseFor[tokenId].to = address(0);
            _leaseFor[tokenId].expiry = 0;
            _leaseOf[claimer] = _leaseOf[claimer] - 1;
        }
        _;
    }

    modifier beforeLease(
        address from,
        address to,
        uint256 tokenId,
        uint256 duration
    ) {
        //To be more sure the receiver is aware of the lease, so to decrease the odds of malicious owners 
        // making ownership transfer deals while delivering lease instead.
        require(duration > 0 && _durations[to][tokenId] == duration, "ERC721Leasable: duractions didn't match");
        //To avoid a user's ERC721Leasable.balanceOf increasing by 2 when a lease to same accounts occurs
        //This can be fixed by checking if the from and to are the same when updating the _leaseOf,
        //but there's no point in doing so. It will only cost normal users more gas fees.
        require(from != to, "ERC721Leasable: can't lease to self");
        
        _leaseFor[tokenId].from = from;
        _leaseFor[tokenId].to = to;
        _leaseFor[tokenId].expiry = block.timestamp + duration;
        _leaseOf[from] = _leaseOf[from] + 1;

        _durations[to][tokenId] = 0;
        _;
    }


    function requestLease(uint256 tokenId, uint256 duration) public virtual {
        require(_exists(tokenId), "ERC721Leasable: token doesn't exist");
        _durations[_msgSender()][tokenId] = duration;
    }

    function leaseRequestOf(address account, uint256 tokenId) public virtual view returns(uint256) {
        require(_exists(tokenId), "ERC721Leasable: token doesn't exist");
        return _durations[account][tokenId];
    }

    /**
     * @dev See {ERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {ERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override claimLease(from, tokenId) {
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    /**
     * @dev See {ERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override claimLease(from, tokenId) {
        super.transferFrom(from, to, tokenId);
    }
    
    function safeLeaseFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 duration
    ) public virtual {
        safeLeaseFrom(from, to, tokenId, duration, "");
    }
    
    function safeLeaseFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 duration,
        bytes memory _data
    ) public virtual claimLease(from, tokenId) beforeLease(from, to, tokenId, duration) {
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function leaseFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 duration
    ) public virtual claimLease(from, tokenId) beforeLease(from, to, tokenId, duration) {
        super.transferFrom(from, to, tokenId);
    }

    function leaseInfo(uint256 tokenId) public virtual view returns (address from, address to, uint256 expiry) {
        from = _leaseFor[tokenId].from;
        to = _leaseFor[tokenId].to;
        expiry = _leaseFor[tokenId].expiry;
    }

    function leaseOf(address owner) public view virtual returns (uint256) {
        return _leaseOf[owner];
    }

    function ownerOf(uint256 tokenId) public virtual override view returns (address) {
        if(_leaseFor[tokenId].from != address(0) && _leaseFor[tokenId].expiry <= block.timestamp) {
            return _leaseFor[tokenId].from;
        }
        return ERC721.ownerOf(tokenId);
    }
    
    function balanceOf(address owner) public view virtual override returns (uint256 balance) {
        return ERC721.balanceOf(owner) + _leaseOf[owner];
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}