/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC20Full {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function mint(address recipient, uint256 amount) external returns (bool);
}

interface IERC20Transfer {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipisent, uint256 amount) external returns (bool);
}

interface ISneakerSnUsers
{
    function isUserExists(address user) external view returns (bool);
    function isUserBotsExists(address user) external view returns (bool);
    function getUser(address user) external view returns (uint,address,uint,uint8,bool);
    function getUserSneakerConditions(address user, uint16 sneaker) external view returns (bool);
    function addUserSneaker(address user, uint8 sneaker, bool activate, bool ignoreConditions) external;
    function getUserSneaker(address user, uint8 sneaker) external view returns (bool,bool,bool,bool,uint16,uint);
    function updateUserSneakerFlag(address user, uint8 sneaker, uint8 flag, bool value) external;
    function updateUserSneakerRCount(address user, uint8 sneaker, uint16 count, bool add) external;
    function getUserReferrer(address user) external view returns (address);
    function getUserReferrer(address user, uint8 sneaker) external view returns (address, bool);
    function getUserAddress(uint user) external view returns (address);
    function isUserSneakerExists(address user, uint8 sneaker) external view returns (bool);
    function setUserSneakerActiveWaiter(address user, uint8 sneaker, uint waiter, bool active) external;
    function getUserSneakerActiveWaiter(address user, uint8 sneaker) external view returns (uint);
    function setUserSneakerConditions(address user, uint8 sneaker) external;
}

contract SneakerSnCompetitionMode {
    address public owner;
    address public snkAddress;
    address public sntAddress;
    address public usersContract;
    //address public exchangeContract;
    //address public liquidityAddress;
    //address public marketingAddress;

    bool public paused;
    bool public rareBonusActive;
    bool public collectionBonusActive;
    bool public burnActive;
    bool public mintSnkActive;
    bool public mintSntActive;

    uint public marketingBonus;
    uint public allReceivedTokens;
    //uint public tokenPrice;
    uint public winChanceBase;
    uint private randNonce;
    uint public nextRunId;
    uint public tokensWon;
    uint public guaranteePrize;

    struct Run {
        address user;
        uint8 sneaker;
        bool winning;
        uint8 place;
        uint8 weather;
        uint8 winChance;
        uint8 randomResult;
        uint betType;
        uint snkPrize;
    }

    mapping (address => bool) public dapps;
    mapping (uint => Run) public runs;
    mapping (uint8 => mapping(uint8 => mapping(uint8 => uint))) public scores;

    uint[] public betTypes;

    event Donate(address indexed user, uint value);
    event RunningResult(address indexed user, uint8 sneaker, uint runId, bool winning, uint snkPrize, uint8 place, uint8 weather, uint winChance, uint rand);
    //event RunningTransfer(uint indexed runId, uint betType, bool winning, uint marketing, uint liquidity);
    event RunningLiquidity(uint runId, uint contractBalance, uint tokenPrice);

    modifier onlyContractOwner() { 
        require(msg.sender == owner, "onlyOwner"); 
        _; 
    }

    modifier onlyDapp() { 
        require(dapps[msg.sender] == true || msg.sender == owner, "onlyDapp"); 
        _; 
    }

    modifier onlyUnpaused() { 
        require(!paused || msg.sender == owner, "paused"); 
        _; 
    }

    function changeSetting(uint8 setting, uint value) external onlyContractOwner() {
        if (setting == 1) {
            paused = !paused;
        } else if (setting == 2) {
            winChanceBase = value;
        } else if (setting == 3) {
            marketingBonus = value;
        } else if (setting == 4) {
            rareBonusActive = !rareBonusActive;
        } else if (setting == 5) {
            collectionBonusActive = !collectionBonusActive;
        } else if (setting == 6) {
            burnActive = !burnActive;
        } else if (setting == 7) {
            guaranteePrize = value;
        } else if (setting == 8) {
            mintSnkActive = !mintSnkActive;
        } else if (setting == 9) {
            mintSntActive = !mintSntActive;
        }
        
        /*else if (setting == 3) {
            tokenPrice = value;
        } else if (setting == 4) {
            marketingBonus = value;
        }  else if (setting == 5) {
            rareBonusActive = !rareBonusActive;
        }  else if (setting == 6) {
            collectionBonusActive = !collectionBonusActive;
        }*/
    }

    function authDapp(address dapp) public onlyContractOwner {
        require(dapp != address(0), "bad dapp address");

        bool dappValue = dapps[dapp];
        dapps[dapp] = !dappValue;
    }

    function changeAddress(uint8 setting, address valueAddress) public onlyContractOwner() {
        if (setting == 1) {
            snkAddress = valueAddress;
        } else if (setting == 2) {
            sntAddress = valueAddress;
        } else if (setting == 3) {
            usersContract = valueAddress;
        }// else if (setting == 4) {
        //    exchangeContract = valueAddress;
        //} //else if (setting == 5) {
        //    marketingAddress = valueAddress;
        //} 
    }

    /*
    function run(uint8 sneaker, uint betType) public payable onlyUnpaused() {
        require(msg.value > 0, "Not enough bnb");
        require(betType > 0, "Bet type invalid");
        require(sneaker > 0, "sneaker invalid");

        ISneakerSnUsers users = ISneakerSnUsers(usersContract);
        require(!users.isUserBotsExists(msg.sender), "user ban");

        bool purchased = false;
        bool transferred = false;
        (purchased,,,transferred,,) = users.getUserSneaker(msg.sender, sneaker);
        require(purchased, "sneaker exists");
        require(!transferred, "sneaker transferred");
        
        _run(sneaker, betType);
    }*/

    function _transfer(address user, uint betType, bool winning) private returns (uint) {
        /*
        uint marketing = (betValue / 1000) * marketingBonus;
        if (marketingAddress == address(0)) {
            payable(owner).transfer(marketing);
        } else {
            payable(marketingAddress).transfer(marketing);
        }

        uint liquidity = betValue - marketing;
        if (liquidityAddress == address(0)) {
            payable(owner).transfer(liquidity);
        } else {
            payable(liquidityAddress).transfer(liquidity);
        }*/

        allReceivedTokens += betType * 1e8;

        if (winning && sntAddress != address(0)) {
            if (mintSntActive) {
                require(IERC20Full(sntAddress).mint(user, betType * 1e8), "error mint SNT");
            } else {
                if (IERC20Full(sntAddress).balanceOf(address(this)) >= betType * 1e8) {
                    require(IERC20Full(sntAddress).transfer(user, betType * 1e8), "error transfer SNT");
                } else {
                    require(IERC20Full(sntAddress).mint(user, betType * 1e8), "error mint SNT");
                }
            }
            tokensWon += betType;
            return betType;
        } else if (!winning && guaranteePrize > 0) {
            uint snkAmount = ((betType * 1e8) / 1000) * guaranteePrize;
            if (snkAddress != address(0)) {
                if (mintSnkActive) {
                    require(IERC20Full(snkAddress).mint(user, snkAmount), "error mint SNK");
                } else {
                    if (IERC20Full(snkAddress).balanceOf(address(this)) >= snkAmount) {
                        require(IERC20Full(snkAddress).transfer(user, snkAmount), "error transfer SNT");
                    } else {
                        require(IERC20Full(snkAddress).mint(user, snkAmount), "error mint SNK");
                    }
                }
                return snkAmount;
            }
        } else {
            return 0;
        }
    }

    function _run(address user, uint8 sneaker, uint betType) private {
        //require(_checkBetType(betType), "Bet type invalid");
        //uint betValue = betType * tokenPrice;
        //require(msg.value == betValue, "Not enough bnb");

        uint rand = _randomMaxMin(user, 1, 100);
        randNonce += rand;
        //allReceivedTokens += betType * 1e8;

        uint8 place = uint8(_randomMaxMin(user, 1, 3));
        randNonce += uint(place);
        uint8 weather = uint8(_randomMaxMin(user, 1, 3));
        randNonce += uint(weather);
        uint winChance = winChanceBase;
        uint score = scores[sneaker][place][weather];
        if (score == 0) {
            revert("score invalid");
        }
        
        if (winChance + 200 < score) {
            winChance = 0;
        } else {
            if (score > 200) {
                winChance += score - 200;
            } else if (score < 200 && score >= 100) {
                winChance -= score - 100;
            }
        }

        score = _getBonusSneakers(user, sneaker);
        if (score > 200) {
            winChance += score - 200;
        } else if (score < 200 && score >= 100) {
            winChance -= score - 100;
        }

        Run memory runValue = Run ({
            user: user,
            sneaker: sneaker,
            winning: false,
            place: place,
            weather: weather,
            winChance: uint8(winChance),
            randomResult: uint8(rand),
            betType: betType,
            snkPrize: 0
        });

        if (winChance >= rand) {
            runValue.winning = true;
            runValue.snkPrize = _transfer(user, betType, true);

            emit RunningResult(user, sneaker, nextRunId, true, runValue.snkPrize, place, weather, winChance, rand);
        } else {
            runValue.snkPrize = _transfer(user, betType, false);
            emit RunningResult(user, sneaker, nextRunId, false, runValue.snkPrize, place, weather, winChance, rand);
        }

        runs[nextRunId] = runValue;
        //_transfer(betType, betValue, nextRunId, true);

        nextRunId++;
    }

    /*
    function _checkBetType(uint betType) private view returns (bool) {
        if (betType == 0) {
            return false;
        }

        bool found = false;
        for (uint i = 0; i < betTypes.length; i++) {
            if (betTypes[i] == betType) {
                found = true;
                break;
            }
        }

        return found;
    }
    */

    function _parseBet(uint value) private view returns (uint8,uint) {
        if (value == 0 || value < 10 * 1e8) {
            return (0, 0);
        }

        uint betType = value / 1e8;

        bool found = false;
        uint8 sneaker = 0;
        for (uint i = 0; i < betTypes.length; i++) {
            if (betTypes[i] == betType) {
                found = true;
                sneaker = uint8(i + 1);
                break;
            }
        }

        if (!found) {
            betType = 0;
        }
        return (sneaker, betType);
    }
            
    function receiveApproval(address spender, uint value, address tokenAddress, bytes memory extraData)
    public 
    onlyUnpaused()
    {
        require(value > 0, "bad value");
        require(spender != address(0), "bad spender");
        //require(extraData.length == 0, "bad extraData");

        if (tokenAddress == snkAddress) {
            IERC20Full token = IERC20Full(tokenAddress);
            require(token.balanceOf(spender) >= value, "tokens not enough");
            uint8 sneaker;
            uint betType;
            (sneaker, betType) = _parseBet(value);
            require(sneaker > 0 && betType > 0, "invalid bet");
            require(token.transferFrom(spender, address(this), value), "error transfer tokens");

            ISneakerSnUsers users = ISneakerSnUsers(usersContract);
            require(!users.isUserBotsExists(spender), "user ban");

            bool purchased = false;
            bool transferred = false;
            (purchased,,,transferred,,) = users.getUserSneaker(spender, sneaker);
            require(purchased, "sneaker exists");
            require(!transferred, "sneaker transferred");

            if (burnActive) {
                token.burn(value);
            }
            
            _run(spender, sneaker, betType);
        } else {
            IERC20 token = IERC20(tokenAddress);
            require(token.transferFrom(spender, address(this), value));
        }
    }

    constructor() public {
        owner = msg.sender;
        paused = false;
        randNonce = block.timestamp;
        //marketingBonus = 200;
        //tokenPrice = 1e16;
        allReceivedTokens = 0;
        nextRunId = 1;
        winChanceBase = 25;
        tokensWon = 0;
        guaranteePrize = 100; //10% in SNK
        rareBonusActive = true;
        collectionBonusActive = true;
        burnActive = false;
        mintSnkActive = false;
        mintSntActive = true;

        snkAddress = address(0xB250E9B5565BE5B5AD63486f65aB922C5Bd0bF86);
        sntAddress = address(0x40d112aFea2F46d766BBec2b98a590Be52EcC75c);
        usersContract = address(0x2F3c2b0EAD7D2157bcE4930f7c7f59cDea889D76);

        _initBetTypes();
        _initScores();
    }

    fallback() external payable onlyUnpaused() {
        _donate();
    }

    receive() external payable onlyUnpaused() {
        _donate();
    }

    function _donate() private {
        payable(owner).transfer(msg.value);

        emit Donate(msg.sender, msg.value);
    }

    function getRunInfo(uint runId) public view returns(address,uint8,bool,uint8,uint8,uint,uint) {
        return (runs[runId].user,
                runs[runId].sneaker,
                runs[runId].winning,
                runs[runId].place,
                runs[runId].weather,
                runs[runId].betType,
                runs[runId].snkPrize);
    }

    function updateRunInfo(uint runId, address user, uint8 sneaker, bool winning, uint8 place, uint8 weather, uint betType, uint snkPrize) public onlyDapp() {
        require(runs[runId].user != address(0), "run exists");

        runs[runId].user = user;
        runs[runId].sneaker = sneaker;
        runs[runId].winning = winning;
        runs[runId].place = place;
        runs[runId].weather = weather;
        runs[runId].betType = betType;
        runs[runId].snkPrize = snkPrize;
    }

    function getRunChance(uint runId) public view returns(uint8,uint8) {
        return (runs[runId].winChance,
                runs[runId].randomResult);
    }

    function updateRunChance(uint runId, uint8 winChance, uint8 randomResult) public onlyDapp() {
        require(runs[runId].user != address(0), "run exists");

        runs[runId].winChance = winChance;
        runs[runId].randomResult = randomResult;
    }

    function getScore(uint8 sneaker, uint8 place, uint8 weather) public view returns(uint) {
        return scores[sneaker][place][weather];
    }

    function updateBetType(uint betTypeId, uint value, bool add) public onlyDapp() {
        if (add) {
            betTypes.push(value);
        } else if (betTypeId < betTypes.length) {
            betTypes[betTypeId] = value;
        }
    }

    function updateScore(uint8 sneaker, uint8 place, uint8 weather, uint value) public onlyDapp() {
        if (sneaker > 0 && place > 0 && weather > 0) {
            scores[sneaker][place][weather] = value;
        }
    }

    function _getBonusSneakers(address user, uint8 sneaker) private view returns (uint) {
        uint bonus = 0;

        ISneakerSnUsers users = ISneakerSnUsers(usersContract);
        if (rareBonusActive) {
            if (sneaker == 1) {
                bonus = 200;
            } else if (sneaker == 2) {
                bonus = 200;
            } else if (sneaker == 3) {
                bonus = 200;
            } else if (sneaker == 4) {
                bonus = 200;
            } else if (sneaker == 5) {
                bonus = 200;
            } else if (sneaker == 6) {
                bonus = 200;
            } else if (sneaker == 7) {
                bonus = 202;
            } else if (sneaker == 8) {
                bonus = 202;
            } else if (sneaker == 9) {
                bonus = 202;
            } else if (sneaker == 10) {
                bonus = 202;
            } else if (sneaker == 11) {
                bonus = 202;
            } else if (sneaker == 12) {
                bonus = 202;
            } else if (sneaker == 13) {
                bonus = 204;
            } else if (sneaker == 14) {
                bonus = 204;
            } else if (sneaker == 15) {
                bonus = 204;
            } else if (sneaker == 16) {
                bonus = 204;
            } else if (sneaker == 17) {
                bonus = 204;
            } else if (sneaker == 18) {
                bonus = 206;
            } else if (sneaker == 19) {
                bonus = 206;
            } else if (sneaker == 20) {
                bonus = 206;
            } else if (sneaker == 21) {
                bonus = 206;
            } else if (sneaker == 22) {
                bonus = 208;
            } else if (sneaker == 23) {
                bonus = 208;
            } else if (sneaker == 24) {
                bonus = 208;
            } else if (sneaker == 25) {
                bonus = 210;
            }
        }

        if (collectionBonusActive) {
            uint sneakersCount = 0;
            (,,,sneakersCount,) = users.getUser(user);
            if (sneakersCount >= 25) {
                bool purchased = false;
                bool transferred = false;
                (purchased,,,transferred,,) = users.getUserSneaker(user, 25);
                if (purchased && !transferred) {
                    if (bonus == 0 || bonus == 200) {
                        bonus == 205;
                    } else if (bonus > 200) {
                        bonus = (bonus - 200) + 205;
                    }
                }
            }
        }
        
        return bonus;
    }

    function _initBetTypes() private {
        betTypes.push(10);
        betTypes.push(15);
        betTypes.push(20);
        betTypes.push(25);
        betTypes.push(30);
        betTypes.push(35);
        betTypes.push(40);
        betTypes.push(50);
        betTypes.push(60);
        betTypes.push(70);
        betTypes.push(80);
        betTypes.push(90);
        betTypes.push(100);
        betTypes.push(200);
        betTypes.push(300);
        betTypes.push(400);
        betTypes.push(500);
        betTypes.push(1000);
        betTypes.push(1500);
        betTypes.push(2000);
        betTypes.push(2500);
        betTypes.push(3000);
        betTypes.push(4000);
        betTypes.push(5000);
        betTypes.push(10000);
    }

    function _initScores() private {
        // 100+: -
        // 200: 0
        // 200+: +
        
        //1
        scores[1][1][1] = 220;
        scores[1][1][2] = 220;
        scores[1][1][3] = 210;
        scores[1][2][1] = 120;
        scores[1][2][2] = 115;
        scores[1][2][3] = 105;
        scores[1][3][1] = 200;
        scores[1][3][2] = 105;
        scores[1][3][3] = 110;

        //2 
        scores[2][1][1] = 220;
        scores[2][1][2] = 220;
        scores[2][1][3] = 210;
        scores[2][2][1] = 120;
        scores[2][2][2] = 115;
        scores[2][2][3] = 105;
        scores[2][3][1] = 200;
        scores[2][3][2] = 105;
        scores[2][3][3] = 110;

        //3
        scores[3][1][1] = 200;
        scores[3][1][2] = 105;
        scores[3][1][3] = 110;
        scores[3][2][1] = 220;
        scores[3][2][2] = 220;
        scores[3][2][3] = 210;
        scores[3][3][1] = 200;
        scores[3][3][2] = 115;
        scores[3][3][3] = 120;

        //4
        scores[4][1][1] = 200;
        scores[4][1][2] = 105;
        scores[4][1][3] = 110;
        scores[4][2][1] = 220;
        scores[4][2][2] = 220;
        scores[4][2][3] = 210;
        scores[4][3][1] = 200;
        scores[4][3][2] = 115;
        scores[4][3][3] = 120;

        //5
        scores[5][1][1] = 220;
        scores[5][1][2] = 220;
        scores[5][1][3] = 210;
        scores[5][2][1] = 120;
        scores[5][2][2] = 115;
        scores[5][2][3] = 200;
        scores[5][3][1] = 200;
        scores[5][3][2] = 105;
        scores[5][3][3] = 110;

        //6
        scores[6][1][1] = 200;
        scores[6][1][2] = 105;
        scores[6][1][3] = 110;
        scores[6][2][1] = 220;
        scores[6][2][2] = 220;
        scores[6][2][3] = 210;
        scores[6][3][1] = 200;
        scores[6][3][2] = 115;
        scores[6][3][3] = 120;

        //7
        scores[7][1][1] = 200;
        scores[7][1][2] = 105;
        scores[7][1][3] = 110;
        scores[7][2][1] = 220;
        scores[7][2][2] = 220;
        scores[7][2][3] = 205;
        scores[7][3][1] = 200;
        scores[7][3][2] = 115;
        scores[7][3][3] = 120;

        //8
        scores[8][1][1] = 200;
        scores[8][1][2] = 105;
        scores[8][1][3] = 110;
        scores[8][2][1] = 220;
        scores[8][2][2] = 220;
        scores[8][2][3] = 205;
        scores[8][3][1] = 200;
        scores[8][3][2] = 115;
        scores[8][3][3] = 120;

        //9
        scores[9][1][1] = 220;
        scores[9][1][2] = 220;
        scores[9][1][3] = 205;
        scores[9][2][1] = 120;
        scores[9][2][2] = 115;
        scores[9][2][3] = 105;
        scores[9][3][1] = 200;
        scores[9][3][2] = 105;
        scores[9][3][3] = 110;

        //10 
        scores[10][1][1] = 200;
        scores[10][1][2] = 105;
        scores[10][1][3] = 110;
        scores[10][2][1] = 220;
        scores[10][2][2] = 220;
        scores[10][2][3] = 205;
        scores[10][3][1] = 200;
        scores[10][3][2] = 115;
        scores[10][3][3] = 120;

        //11
        scores[11][1][1] = 220;
        scores[11][1][2] = 220;
        scores[11][1][3] = 205;
        scores[11][2][1] = 120;
        scores[11][2][2] = 115;
        scores[11][2][3] = 105;
        scores[11][3][1] = 200;
        scores[11][3][2] = 105;
        scores[11][3][3] = 110;

        //12
        scores[12][1][1] = 200;
        scores[12][1][2] = 105;
        scores[12][1][3] = 110;
        scores[12][2][1] = 220;
        scores[12][2][2] = 220;
        scores[12][2][3] = 205;
        scores[12][3][1] = 200;
        scores[12][3][2] = 115;
        scores[12][3][3] = 120;

        //13 
        scores[13][1][1] = 200;
        scores[13][1][2] = 105;
        scores[13][1][3] = 110;
        scores[13][2][1] = 120;
        scores[13][2][2] = 115;
        scores[13][2][3] = 105;
        scores[13][3][1] = 220;
        scores[13][3][2] = 205;
        scores[13][3][3] = 200;

        //14
        scores[14][1][1] = 220;
        scores[14][1][2] = 210;
        scores[14][1][3] = 205;
        scores[14][2][1] = 120;
        scores[14][2][2] = 115;
        scores[14][2][3] = 105;
        scores[14][3][1] = 200;
        scores[14][3][2] = 105;
        scores[14][3][3] = 110;

        //15
        scores[15][1][1] = 220;
        scores[15][1][2] = 210;
        scores[15][1][3] = 205;
        scores[15][2][1] = 115;
        scores[15][2][2] = 110;
        scores[15][2][3] = 105;
        scores[15][3][1] = 220;
        scores[15][3][2] = 210;
        scores[15][3][3] = 205;

        //16 
        scores[16][1][1] = 220;
        scores[16][1][2] = 210;
        scores[16][1][3] = 205;
        scores[16][2][1] = 115;
        scores[16][2][2] = 110;
        scores[16][2][3] = 105;
        scores[16][3][1] = 220;
        scores[16][3][2] = 210;
        scores[16][3][3] = 205;

        //17
        scores[17][1][1] = 220;
        scores[17][1][2] = 210;
        scores[17][1][3] = 205;
        scores[17][2][1] = 115;
        scores[17][2][2] = 110;
        scores[17][2][3] = 105;
        scores[17][3][1] = 220;
        scores[17][3][2] = 210;
        scores[17][3][3] = 205;

        //18
        scores[18][1][1] = 210;
        scores[18][1][2] = 200;
        scores[18][1][3] = 200;
        scores[18][2][1] = 115;
        scores[18][2][2] = 110;
        scores[18][2][3] = 110;
        scores[18][3][1] = 210;
        scores[18][3][2] = 200;
        scores[18][3][3] = 200;

        //19
        scores[19][1][1] = 210;
        scores[19][1][2] = 200;
        scores[19][1][3] = 200;
        scores[19][2][1] = 115;
        scores[19][2][2] = 110;
        scores[19][2][3] = 110;
        scores[19][3][1] = 210;
        scores[19][3][2] = 200;
        scores[19][3][3] = 200;

        //20 
        scores[20][1][1] = 210;
        scores[20][1][2] = 200;
        scores[20][1][3] = 200;
        scores[20][2][1] = 115;
        scores[20][2][2] = 110;
        scores[20][2][3] = 110;
        scores[20][3][1] = 210;
        scores[20][3][2] = 205;
        scores[20][3][3] = 200;

        //21 
        scores[21][1][1] = 210;
        scores[21][1][2] = 205;
        scores[21][1][3] = 205;
        scores[21][2][1] = 115;
        scores[21][2][2] = 110;
        scores[21][2][3] = 110;
        scores[21][3][1] = 210;
        scores[21][3][2] = 205;
        scores[21][3][3] = 205;

        //22
        scores[22][1][1] = 215;
        scores[22][1][2] = 210;
        scores[22][1][3] = 210;
        scores[22][2][1] = 115;
        scores[22][2][2] = 110;
        scores[22][2][3] = 105;
        scores[22][3][1] = 220;
        scores[22][3][2] = 210;
        scores[22][3][3] = 210;

        //23
        scores[23][1][1] = 215;
        scores[23][1][2] = 215;
        scores[23][1][3] = 215;
        scores[23][2][1] = 115;
        scores[23][2][2] = 110;
        scores[23][2][3] = 105;
        scores[23][3][1] = 220;
        scores[23][3][2] = 215;
        scores[23][3][3] = 215;

        //24 
        scores[24][1][1] = 220;
        scores[24][1][2] = 215;
        scores[24][1][3] = 215;
        scores[24][2][1] = 110;
        scores[24][2][2] = 105;
        scores[24][2][3] = 105;
        scores[24][3][1] = 220;
        scores[24][3][2] = 215;
        scores[24][3][3] = 215;

        //25 
        scores[25][1][1] = 215;
        scores[25][1][2] = 215;
        scores[25][1][3] = 215;
        scores[25][2][1] = 200;
        scores[25][2][2] = 210;
        scores[25][2][3] = 205;
        scores[25][3][1] = 215;
        scores[25][3][2] = 215;
        scores[25][3][3] = 215;
    }

    function _randomMaxMin(address user, uint min, uint max) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(msg.sender, user, block.timestamp, allReceivedTokens, randNonce))) % (max - min + 1) + min;
    }

    function withdraw(address token) public onlyContractOwner {
        if (token == address(0)) {
            address payable ownerPayable = payable(owner);
            ownerPayable.transfer(address(this).balance);
        } else {
            IERC20Transfer(token).transfer(owner, IERC20Transfer(token).balanceOf(address(this)));
        }
    }
}