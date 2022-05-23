// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./ReentrancyGuard.sol";
import "./AggregatorV3Interface.sol";


interface ERC20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
}


interface CreamYield {
    
    function mint(uint mintAmount) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getCash() external view returns (uint);
    function underlying() external view returns (address);
}


contract MecenasV5 is ReentrancyGuard {

    address public constant EMPTY_ADDRESS = address(0);
    uint public immutable LOCK_LOTTERY;

    CreamYield public marketcream;
    ERC20 public underlying;
    AggregatorV3Interface internal priceFeed;
    
    uint public totalseekerinterest;
    uint public totaldevelopinterest;
    uint public reservevalue;
    uint public totalinterestpaid;
    uint public totalreservepaid;
    uint public supporters;
    uint public lockdeposits;
    uint public jackpotvalue;
    uint public interestvalue;
    uint80 private nonce;
    uint private blockNumber;
    
    uint public generatorRNG;

    bool public spinning;
    bool public picking;

    uint public jackpotsettled;
    uint public timejackpot;

    uint public jackpotspaid;
    uint public developsettled;
    uint public seekersettled;
    uint public balancedonations;
    uint public totaldonations;
    uint public totaldonationspaid;

    mapping(address => uint) public balancedonators;
    mapping(address => uint) public balancepatrons;

    uint public balancepool;

    uint public decimalstoken;
    string public nametoken;

    address[] private players;
    
    mapping(address => uint) private indexplayers;
    
    address public owner;
    address public developer;
    address public seeker;

    uint public lotterycounter;
    
    struct Lottery {
        uint lotteryid;
        uint lotterydate;
        uint lotteryresult;
        address lotterywinner;
        uint lotteryamount;
        uint datablock;
        uint80 datanonce;
    }    
    
    Lottery[] public lotteryResults;
    
    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed to, uint amount);
    event DepositDonation(address indexed from, uint amount);
    event WithdrawDonation(address indexed to, uint amount);
    event CollectYield(address indexed to, uint amount, uint transtype);
    event PayWinner(address indexed to, uint amount);
    event PayDeveloper(address indexed to, uint amount);
    event PaySeeker(address indexed to, uint amount);
    event ChangeOwner(address indexed oldowner, address indexed newowner);
    event ChangeDeveloper(address indexed olddeveloper, address indexed newdeveloper);
    event ChangeSeeker(address indexed oldseeker, address indexed newseeker);
    event ChangePoolLock(address indexed ownerchanger, uint oldlock, uint newlock);
    event LotteryAwarded(uint counter, uint date, address indexed thewinner, uint amount, uint result);
    event ChangeGeneratorRNG(address indexed ownerchanger, uint oldRNG, uint newRNG);

    
    constructor(address _owner, address _marketcream, address _developer, address _seeker, uint _cyclelottery, address _priceFeed, uint _generatorRNG) {
        
        marketcream = CreamYield(_marketcream);
        underlying = ERC20(marketcream.underlying());
        owner = _owner;
        developer = _developer;
        seeker = _seeker;
        decimalstoken = underlying.decimals();
        nametoken = underlying.symbol();
        LOCK_LOTTERY = _cyclelottery;
        priceFeed = AggregatorV3Interface(_priceFeed);
        generatorRNG = _generatorRNG;
    }


    // Checks if msg.sender is the owner
    
    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }


    // Returns historical price feed

    function getHistoricalPrice(uint80 roundId) internal view returns (int, uint) {
        (,int price, uint startedAt,,) = priceFeed.getRoundData(roundId);
        
        return (price, startedAt);
    }


    // Returns latest price feed

    function getLatestPrice() internal view returns (uint80) {
        (uint80 roundID,,,,) = priceFeed.latestRoundData();
        return roundID;
    }

    
    // Modifies the address of the owner
    
    function transferowner(address _newowner) external onlyowner {
        require(_newowner != EMPTY_ADDRESS);
        address oldowner = owner;
        owner = _newowner;
    
        emit ChangeOwner(oldowner, owner);
    }


    // Modifies the address of the developer

    function transferdeveloper(address _newdeveloper) external {
        require(_newdeveloper != EMPTY_ADDRESS && msg.sender == developer);
        address olddeveloper = developer;
        developer = _newdeveloper;
    
        emit ChangeDeveloper(olddeveloper, developer);
    }


    // Modifies the address of the seeker

    function transferseeker(address _newseeker) external {
        require(_newseeker != EMPTY_ADDRESS && msg.sender == seeker);
        address oldseeker = seeker;
        seeker = _newseeker;
    
        emit ChangeSeeker(oldseeker, seeker);
    }


    // Locks or unlocks functions deposit() and depositdonation()
    // 0 = unlock 
    // 1 = lock
    
    function lockpool(uint _lockdeposits) external onlyowner {
        require(_lockdeposits == 1 || _lockdeposits == 0);
        uint oldlockdeposits = lockdeposits;
        lockdeposits = _lockdeposits;
    
        emit ChangePoolLock(owner, oldlockdeposits, lockdeposits);
    }
    

    // Changes RNG generator
    // 1 = PRICE FEED 
    // 1 = FUTURE BLOCKHASH
    
    function changegenerator(uint _newRNG) external onlyowner {
        require(_newRNG == 1 || _newRNG == 2);
        uint oldRNG = generatorRNG;
        generatorRNG = _newRNG;
        spinning = false;
        picking = false;
        jackpotsettled = 0;
        developsettled = 0;
        seekersettled = 0;
    
        emit ChangeGeneratorRNG(owner, oldRNG, generatorRNG);
    }


    // Deposit underlying and participate in lottery
        
    function deposit(uint _amount) external nonReentrant {
        require(!spinning && lockdeposits == 0 && msg.sender != EMPTY_ADDRESS);
        require(_amount > 0 && underlying.balanceOf(msg.sender) >= _amount);
        require(underlying.allowance(msg.sender, address(this)) >= _amount);
        
        require(underlying.transferFrom(msg.sender, address(this), _amount));
        
        if (balancepatrons[msg.sender] == 0) {
            supporters += 1;
            players.push(msg.sender);
            indexplayers[msg.sender] = players.length - 1;
        }

        if (supporters > 0 && timejackpot == 0 && !spinning) {
            timejackpot = block.timestamp;
        }
        
        require(underlying.approve(address(marketcream), _amount));
        require(marketcream.mint(_amount) == 0);   

        balancepatrons[msg.sender] += _amount;
        balancepool += _amount;
        
        emit Deposit(msg.sender, _amount);
    }
    
    
    // Deposit underlying
  
    function depositdonation(uint _amount) external nonReentrant {
        require(lockdeposits == 0 && msg.sender != EMPTY_ADDRESS);
        require(_amount > 0 && underlying.balanceOf(msg.sender) >= _amount);
        require(underlying.allowance(msg.sender, address(this)) >= _amount);
        
        require(underlying.transferFrom(msg.sender, address(this), _amount));
        
        require(underlying.approve(address(marketcream), _amount));
        require(marketcream.mint(_amount) == 0);   

        balancedonators[msg.sender] += _amount;
        balancedonations += _amount;
        totaldonations += _amount;
                
        emit DepositDonation(msg.sender, _amount);
    }
    
    
    // Withdraw underlying deposited with function deposit()
        
    function withdraw(uint _amount) external nonReentrant {
        require(!spinning && msg.sender != EMPTY_ADDRESS);
        require(_amount > 0 && balancepatrons[msg.sender] >= _amount);
        require(marketcream.getCash() >= _amount);
        
        balancepatrons[msg.sender] -= _amount; 
        balancepool -= _amount;

        require(marketcream.redeemUnderlying(_amount) == 0);

        if (balancepatrons[msg.sender] == 0) {
            supporters -= 1;
                
            uint index = indexplayers[msg.sender];
            uint indexmove = players.length - 1;
            address addressmove = players[indexmove];
                
            if (index == indexmove) {
                delete indexplayers[msg.sender];
                players.pop();
                    
            } else {
                delete indexplayers[msg.sender];
                players[index] = addressmove;
                indexplayers[addressmove] = index;
                players.pop();
            }
        } 
        
        if (supporters == 0) {
            timejackpot = 0;
            spinning = false;
            picking = false;
            jackpotsettled = 0;
            developsettled = 0;
            seekersettled = 0;
        }    
        
        require(underlying.transfer(msg.sender, _amount));
    
        emit Withdraw(msg.sender, _amount);
    }


    // Accrues yield and splits into interests, reserves and jackpot
    
    function splityield() internal {
        uint interest = interestaccrued();
        
        uint totransferinterest = interest * (50 * 10 ** decimalstoken / 100);
        totransferinterest = totransferinterest / 10 ** decimalstoken;
        interestvalue += totransferinterest;
        
        uint jackpotinterest = interest * (25 * 10 ** decimalstoken / 100);
        jackpotinterest = jackpotinterest / 10 ** decimalstoken;
        jackpotvalue += jackpotinterest;
        
        uint reserveinterest = interest - totransferinterest - jackpotinterest;
        reservevalue += reserveinterest;
    }


    // Calculates yield generated in yield source
    
    function interestaccrued() internal returns (uint) {
        uint interest = (marketcream.balanceOfUnderlying(address(this)) - balancepool - balancedonations - reservevalue - jackpotvalue - interestvalue); 
        return interest;
    }


    // Settles the prize and seeds with block number and nonce to be used to generate random number
    
    function settlejackpot() external nonReentrant {
        
        require(!spinning && supporters > 0 && timejackpot > 0 && block.number > blockNumber);
        
        uint end = block.timestamp;
        uint totaltime = end - timejackpot;
        require(totaltime >= LOCK_LOTTERY);

        spinning = true;
        timejackpot = 0;
        blockNumber = block.number + 5;

        splityield();
    
        require(jackpotvalue > 0);
        
        jackpotsettled = jackpotvalue;
        uint distjackpot = jackpotsettled;
        
        developsettled = distjackpot * (20 * 10 ** decimalstoken / 100);
        developsettled = developsettled / 10 ** decimalstoken;
        seekersettled = distjackpot * (5 * 10 ** decimalstoken / 100);
        seekersettled = seekersettled / 10 ** decimalstoken;
        
        jackpotsettled = jackpotsettled - developsettled - seekersettled;
        
        if (generatorRNG == 1) {
            nonce = getLatestPrice() + 5;
        }

        if (generatorRNG == 2) {
            nonce++;
        }

        picking = true;
    }
    
    
    // RNG (random number generator)
    
    function generaterandomnumber() internal view returns (uint) {
        
        uint randnum;

        if (generatorRNG == 1) {
        (int theprice, uint thestartround) = getHistoricalPrice(nonce);
        randnum = uint(keccak256(abi.encode(blockhash(block.number - 1), theprice, thestartround))) % players.length;
        }
        
        if (generatorRNG == 2) {
        randnum = uint(keccak256(abi.encode(blockhash(blockNumber), nonce))) % players.length;
        }

        return randnum;  
    }


    // Awards a winner of the lottery
        
    function pickawinner() external nonReentrant {
        
        if (generatorRNG == 1) {
        require(picking && getLatestPrice() > nonce);
        }

        if (generatorRNG == 2) {
        require(picking && block.number > blockNumber);
        }

        uint toredeem =  jackpotsettled + developsettled + seekersettled;
        require(marketcream.getCash() >= toredeem);  
        
        uint totransferbeneficiary = jackpotsettled;
        uint totransferdevelop = developsettled;
        uint totransferseeker = seekersettled;
        
        jackpotsettled = 0;
        developsettled = 0;
        seekersettled = 0;
        
        lotterycounter++;
        uint end = block.timestamp;
        
        if (block.number - blockNumber > 250 && generatorRNG == 2) {
    
            lotteryResults.push(Lottery(lotterycounter, end, 2, EMPTY_ADDRESS, 0, blockNumber, nonce));

            emit LotteryAwarded(lotterycounter, end, EMPTY_ADDRESS, 0, 2);
        
        } else {
            
            uint randomnumber = generaterandomnumber();
            address beneficiary = players[randomnumber];
            
            jackpotspaid += totransferbeneficiary;
            totaldevelopinterest += totransferdevelop;
            totalseekerinterest += totransferseeker;
            
            require(marketcream.redeemUnderlying(toredeem) == 0);
            jackpotvalue -= toredeem;
            
            require(underlying.transfer(beneficiary, totransferbeneficiary));
            require(underlying.transfer(developer, totransferdevelop));
            require(underlying.transfer(seeker, totransferseeker));
                
            lotteryResults.push(Lottery(lotterycounter, end, 1, beneficiary, totransferbeneficiary, blockNumber, nonce));
        
            emit PayWinner(beneficiary, totransferbeneficiary);
            emit PayDeveloper(developer, totransferdevelop);
            emit PaySeeker(seeker, totransferseeker);
            
            emit LotteryAwarded(lotterycounter, end, beneficiary, totransferbeneficiary, 1);
        }
          
        timejackpot = block.timestamp;
        spinning = false;
        picking = false;
    }
        
    
    // Returns the timeleft to execute function settlejackpot()
    // 0 = no time left

    function calculatetimeleft() public view returns (uint) {
        uint end = block.timestamp;
        uint totaltime = end - timejackpot;
        
        if(totaltime < LOCK_LOTTERY) {
            uint timeleft = LOCK_LOTTERY - totaltime;
            return timeleft;
        } else {
            return 0;
        }
    }
    
    
    // Returns if conditions are met to execute function settlejackpot()
    // 1 = met
    // 2 = not met 
    
    function calculatesettlejackpot() public view returns (uint) {
        
        uint end = block.timestamp;
        uint totaltime = end - timejackpot;

        if (!spinning && supporters > 0 && timejackpot > 0 && block.number > blockNumber && totaltime >= LOCK_LOTTERY) {
            return 1;
    
        } else {
            return 2;
        }    
    }        
            
    
    // Returns if conditions are met to execute function pickawinner()
    // 1 = met
    // 2 = not met 
        
    function calculatepickawinner() public view returns (uint) {
        
        uint toredeem = jackpotsettled + developsettled + seekersettled;
        uint metwinner;
        
        if (generatorRNG == 1) {
            if (picking && marketcream.getCash() >= toredeem && getLatestPrice() > nonce) {
                metwinner = 1;
            } else {
                metwinner = 2;
            }
        }

        if (generatorRNG == 2) {
            if (picking && block.number > blockNumber && marketcream.getCash() >= toredeem) {
                metwinner = 1;
            } else {
                metwinner = 2;
            }
        }
        
        return metwinner;
    }
    
    
    // Returns if account is the owner
    // 1 = is owner
    // 2 = is not owner
    
    function verifyowner(address _account) public view returns (uint) {
        
        if (_account == owner) {
            return 1;
        } else {
            return 2;
        }
    }
    
  
    // Returns an array of struct of jackpots drawn results
  
    function getLotteryResults() external view returns (Lottery[] memory) {
    return lotteryResults;
    }
  
    
    // Withdraw interests and reserves by the owner
    // flag 1 = interests
    // flag 2 = reserves

    function withdrawyield(uint _amount, uint _flag) external nonReentrant onlyowner {
        require(_amount > 0 && (_flag == 1 || _flag == 2));
        require(marketcream.getCash() >= _amount);  

        splityield();
        
        if (_flag == 1) {
        require(_amount <= interestvalue);
        totalinterestpaid += _amount;
        interestvalue -= _amount;
        }
        
        if (_flag == 2) {
        require(_amount <= reservevalue);
        totalreservepaid += _amount;
        reservevalue -= _amount;
        }
        
        require(marketcream.redeemUnderlying(_amount) == 0);
        require(underlying.transfer(owner, _amount));

        emit CollectYield(owner, _amount, _flag);
    }
    
    
    // Withdraw donations by the owner     
    
    function withdrawdonations(uint _amount) external nonReentrant onlyowner {
        require(_amount > 0);
        require(balancedonations >= _amount);
        require(marketcream.getCash() >= _amount);  
        
        require(marketcream.redeemUnderlying(_amount) == 0);
        balancedonations -= _amount;
        totaldonationspaid += _amount;
        
        require(underlying.transfer(owner, _amount));

        emit WithdrawDonation(owner, _amount);
    }
    

    // Returns yield generated
    // _amount = balance of underlying of yieldsource
    
    function calculateinterest(uint _amount) external view returns(uint, uint, uint) {
        
        uint yield = (_amount - balancepool - balancedonations - reservevalue - jackpotvalue - interestvalue);
        
        uint interest = yield * (50 * 10 ** decimalstoken / 100);
        interest = interest / 10 ** decimalstoken;
        
        uint reserve = yield * (25 * 10 ** decimalstoken / 100);
        reserve = reserve / 10 ** decimalstoken;
        
        uint jackpot = yield - interest - reserve;
        
        interest += interestvalue;
        reserve += reservevalue;
        jackpot = jackpot + jackpotvalue - jackpotsettled - developsettled - seekersettled;
    
        jackpot = jackpot * (75 * 10 ** decimalstoken / 100);
        jackpot = jackpot / 10 ** decimalstoken;
        
        return (interest, reserve, jackpot);
    }
    

    // Returns data to the front end

    function calculatedata() external view returns (uint [] memory) {
        
        uint[] memory datafront = new uint[](19);
        
        datafront[0] = balancepool + balancedonations;
        datafront[1] = marketcream.getCash();
        datafront[2] = calculatetimeleft();
        datafront[3] = calculatesettlejackpot();
        datafront[4] = calculatepickawinner();
        datafront[5] = totalinterestpaid;
        datafront[6] = totalreservepaid;
        datafront[7] = totaldonationspaid;
        datafront[8] = balancedonations;
        datafront[9] = totaldonations;
        datafront[10] = jackpotsettled;
        datafront[11] = jackpotspaid;
        datafront[12] = lockdeposits;
        datafront[13] = supporters;
        datafront[14] = LOCK_LOTTERY;
        datafront[15] = decimalstoken;
        datafront[16] = balancepool;
        datafront[17] = lotterycounter;        
        datafront[18] = generatorRNG;

        return (datafront);
    }

   
   // Returns data to the front end
    
    function calculatedataaccount(address _account) external view returns (uint [] memory) {
        require(_account != EMPTY_ADDRESS);

        uint[] memory datafrontaccount = new uint[](5);
        
        datafrontaccount[0] = balancepatrons[_account];
        datafrontaccount[1] = underlying.balanceOf(_account);
        datafrontaccount[2] = underlying.allowance(_account, address(this));
        datafrontaccount[3] = verifyowner(_account);
        datafrontaccount[4] = balancedonators[_account];
        
        return (datafrontaccount);
    }


    // Checks conditions of transactions
    // flag 1 = deposits
    // flag 2 = donations
    // flag 3 = withdraw
    // flag 4 = withdraw donations
    // flag 5 = withdraw yield

    function checkoperations(uint _amount, uint _amount1, address _account, uint _flag) external view returns (uint) {
                
        uint result = 0;
        
        if (lockdeposits == 1 && (_flag == 1 || _flag == 2)) {
            result = 1;
        } else {
            if (spinning && (_flag == 1 || _flag == 3)) {
                result = 2;
            } else {
                if (_amount > underlying.balanceOf(_account) && (_flag == 1 || _flag == 2)) {
                    result = 3;
                } else {
                    if (_amount > underlying.allowance(_account, address(this)) && (_flag == 1 || _flag == 2)) {
                        result = 4;
                    } else {
                        if (_amount > balancepatrons[_account] && _flag == 3) {
                            result = 5;            
                        } else {
                             if (verifyowner(_account) == 2 && (_flag == 4 || _flag == 5)) {
                                result = 6;
                            } else {
                                if (_amount > balancedonations && _flag == 4) {
                                    result = 7;
                                } else {
                                    if (_amount > _amount1 && _flag == 5) {
                                        result = 8;
                                    } else {
                                        if (_amount > marketcream.getCash() && (_flag == 3 || _flag == 4 || _flag == 5)) {
                                            result = 9;
                                        }
                                    }
                                }
                            }     
                        }
                    }                        
                }
            }
        }
        
        return result;
    }

}