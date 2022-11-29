// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Uncomment this line to use console.log
//import "hardhat/console.sol";

contract ArcadeManager {
    // We received only 3 tokens
    IERC20 public BUSDToken;
    IERC20 public DAIToken;
    IERC20 public BONKToken;

    address payable public owner;
    address payable public manager;

    // Interest rate when doing transaction 
    uint public interestRate; // If we want to set it as 0.001% we will set it as 100000

    // Keep track of tokens
    uint public BUSDTotalSupply;
    uint public DAITotalSupply;
    uint public BONKTotalSupply;

    // Token Set Price
    uint public BONKToStablePrice;
    
    mapping(address => uint) public userBONKToBAMReserve;

    // Events
    event SetToken(IERC20 tokenFrom, address tokenTo, uint time);
    event SetManager(address manager, uint time);
    event SetInterestRate(address user, uint interestRate, uint time);
    event SetBONKPrice(uint oldPrice, uint  newPrice, uint time); // Event for set BONK price 
    event Deposit(address token, uint amount, uint time);
    event DistributeReward(address token, address user, uint amount, uint time);
    event Withdraw(address token, address user, uint amount, uint time);
    event ExchangeToken(address tokenA, address tokenB, uint exchangeFrom, uint exchangeTo, uint fees, uint time); // Event for Exchange Token
    event ExchangeBONKToBAM(address user, uint amount, uint time);
    event ExchangeBAMToBONK(address user, uint amount, uint time);
    event ClearReserveBONK(address user, uint amount, uint time);

    constructor(address _BUSDToken, address _DAIToken, address _BONKToken, address _manager, uint _interestRate, uint _BONKPrice) {
        owner = payable(msg.sender);
        BUSDToken = IERC20(_BUSDToken);
        DAIToken = IERC20(_DAIToken);
        BONKToken = IERC20(_BONKToken);
        manager = payable(_manager);
        interestRate = _interestRate;
        BUSDTotalSupply = 0;
        DAITotalSupply = 0;
        BONKTotalSupply = 0;
        BONKToStablePrice = _BONKPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "not authorized");
        _;
    }

    // Need to be test
    modifier onlyVIP() {
        bool result;
        if (msg.sender == owner || msg.sender == manager) {
            result = true;
        }else {
            result = false;
        }
        require(result, "not authorized");
        _;
    }

    modifier validateExchangeToken(address _tokenA, address _tokenB) {
        IERC20 convertTokenA = IERC20(_tokenA); // convert token 
        IERC20 convertTokenB = IERC20(_tokenB);
        bool validateTokenA = false;
        bool validateTokenB = false;
        bool result = false;

        if (convertTokenA == BONKToken || convertTokenA == DAIToken || convertTokenA == BUSDToken) {
            validateTokenA = true;
        }

        if (convertTokenB == BONKToken || convertTokenB == DAIToken || convertTokenB == BUSDToken) {
            validateTokenB = true;
        }

        if (validateTokenA && validateTokenB) { 
            result = true; 
        }

        require(result, "invalid token"); 
        _;
    }

    // Inner function only 
    function checkSupply(IERC20 token, uint _amount) public view returns (bool success) {
        if (token == BONKToken) {
            if (BONKTotalSupply >=  _amount) {
                return true;
            }
            return false;
        } else if (token == BUSDToken) {
            if (BUSDTotalSupply >= _amount) {
                return true;
            }
            return false;
        } else if (token == DAIToken) {
            if (DAITotalSupply >= _amount) {
                return true;
            }
            return false;
        } 
        return false;
    }

    // Owner Function Only
    function setInterestRate(uint _interestRate) external onlyOwner {
        emit SetInterestRate(msg.sender, _interestRate, block.timestamp);
        interestRate = _interestRate;
    }

    function setManagerAddress(address _manager) external onlyOwner {
        emit SetManager(_manager, block.timestamp);
        manager = payable(_manager);   
    }

    function setBONKToken(address _token) external onlyOwner {
        emit SetToken(BONKToken, _token, block.timestamp);
        BONKToken = IERC20(_token);
    }

    function setDAIToken(address _token) external onlyOwner {
        emit SetToken(DAIToken, _token, block.timestamp);
        DAIToken = IERC20(_token);
    }

    function setBUSDToken(address _token) external onlyOwner {
        emit SetToken(BUSDToken, _token, block.timestamp);
        BUSDToken = IERC20(_token);
    }

    function setBONKPrice(uint _price) external onlyVIP {
        emit SetBONKPrice(BONKToStablePrice, _price, block.timestamp);
        BONKToStablePrice = _price; 
    }

    // Let user deposit token to arcade
    function deposit(address _token, uint _amount) external {
        require(_amount > 0, "Deposit amount cannot be zero");
        IERC20 convert = IERC20(_token);
        if (convert == BONKToken) {
            emit Deposit(_token, _amount, block.timestamp);
            BONKToken.transferFrom(msg.sender, address(this), _amount);
            BONKTotalSupply += _amount;
        } else if (convert == BUSDToken) {
            emit Deposit(_token, _amount, block.timestamp);
            BUSDToken.transferFrom(msg.sender, address(this), _amount);
            BUSDTotalSupply += _amount;
        } else if (convert == DAIToken) {
            emit Deposit(_token, _amount, block.timestamp);
            DAIToken.transferFrom(msg.sender, address(this), _amount);
            DAITotalSupply += _amount;
        } else {
            revert("Token's address mismatched");
        }
    }

    // Clear Reserve
    function clearReserveBONK(address _account) external onlyVIP returns (bool result){
        uint amount = userBONKToBAMReserve[_account];
        userBONKToBAMReserve[_account] = 0;
        emit ClearReserveBONK(_account, amount, block.timestamp);
        return true;
    }

    // Special for BONK to BAM 
    function exchangeBONKToBAM(uint _amount) external {
        require(_amount > 0, "Swap amount cannot be zero");
        uint serviceCharge = _amount / interestRate;
        uint totalAmount = _amount - serviceCharge;

        if (msg.sender != address(0)) {
            BONKToken.transferFrom(msg.sender, address(this), _amount);
            BONKTotalSupply += totalAmount;
            userBONKToBAMReserve[msg.sender] = totalAmount;
            emit ExchangeBONKToBAM(msg.sender, _amount, block.timestamp);
        } else {
            revert("Address is not correct");
        }
    }

    // Swap out BAM -> BONK
    function exchangeBAMToBONK(address _account, uint _amount) external onlyVIP {
        require(_amount > 0, "Reward amount cannot be zero");
        uint serviceCharge = _amount / interestRate;
        uint totalAmount = _amount - serviceCharge;
        bool overload = _amount > BONKTotalSupply;
        if (overload) {
            revert("The amount of swap exceed supply");
        }
        BONKTotalSupply -= totalAmount;
        userBONKToBAMReserve[_account] = 0;
        BONKToken.transfer(_account, totalAmount);
        emit ExchangeBAMToBONK(_account, totalAmount, block.timestamp);
    }

    // Send token to user as reward
    function distributeReward(address _token, address _user, uint _amount) external onlyVIP {
        require(_amount > 0, "Reward amount cannot be zero");
        // Calculate service charge
        //uint serviceCharge = _amount.div(interestRate);
        uint serviceCharge = _amount / interestRate;
        uint totalAmount = _amount - serviceCharge;
        // Check whether it exceed supply or not
        IERC20 convert = IERC20(_token);
        if (convert == BONKToken) {
            bool overload = _amount > BONKTotalSupply;
            if (overload) {
                revert("The amount of distribute exceed supply");
            }
            emit DistributeReward(_token, _user, _amount, block.timestamp);
            BONKTotalSupply -= totalAmount;
            BONKToken.transfer(_user, totalAmount); // Transfer to said user
        } else if (convert == BUSDToken) {
            bool overload = _amount > BUSDTotalSupply;
            if (overload) {
                revert("The amount of distribute exceed supply");
            }
            emit DistributeReward(_token, _user, _amount, block.timestamp);
            BUSDTotalSupply -= totalAmount;
            BUSDToken.transfer(_user, totalAmount);
        } else if (convert == DAIToken) {
            bool overload = _amount > DAITotalSupply;
            if (overload) {
                revert("The amount of distribute exceed supply");
            }
            emit DistributeReward(_token, _user, _amount, block.timestamp);
            DAITotalSupply -= totalAmount;
            DAIToken.transfer(_user, totalAmount);
        } else {
            revert("Token's address mismatched");
        }
    }

    function BONKToStableCalculator(uint _amount) public view returns (uint result) {
        require(_amount > 0, "Amount cannot be zero");
        uint calculate = _amount * BONKToStablePrice;
        return calculate;
    } 

    function StableToBONKCalculator(uint _amount) public view returns (uint result) {
        require(_amount > 0, "Amount cannot be zero");
        uint calculate = _amount / BONKToStablePrice;
        return calculate;
    }

    // Exchange for BUSD <-> BONK || DAI <-> BONK
    function exchange(address _tokenA, address _tokenB, uint _amount) external validateExchangeToken(_tokenA, _tokenB) {
        
        require(_amount > 0, "Withdraw amount cannot be zero");
       
        address tokenAddressA = _tokenA;
        address tokenAddressB = _tokenB;

        IERC20 tokenA = IERC20(tokenAddressA);
        IERC20 tokenB = IERC20(tokenAddressB);
        
        uint exchangeRate;
        uint serviceCharge;
        uint totalExchange;
        uint originRate = _amount;


        // Case 1 : BONK -> DAI 
        if (tokenA == BONKToken && tokenB == DAIToken) {

            exchangeRate = BONKToStableCalculator(originRate);
            serviceCharge = exchangeRate / interestRate; // Calculate service fees 
            totalExchange = exchangeRate - serviceCharge;

            bool check = checkSupply(tokenB, totalExchange); // Check whether we have enough supply for the transfer or not

            if (check) {

                BONKTotalSupply += originRate;
                DAITotalSupply -= totalExchange;
                
                BONKToken.transferFrom(msg.sender, address(this), originRate);
                DAIToken.transfer(msg.sender, totalExchange);

                emit ExchangeToken(tokenAddressA , tokenAddressB , originRate, totalExchange, serviceCharge, block.timestamp);
            } else {
                revert("Supply is insufficient");
            }
        } 
        // Case 2 : BONK -> BUSD
        else if (tokenA == BONKToken && tokenB == BUSDToken) {
            
            exchangeRate = BONKToStableCalculator(originRate);
            serviceCharge = exchangeRate / interestRate;
            totalExchange = exchangeRate - serviceCharge;
            
            bool check = checkSupply(tokenB, totalExchange);
            
            if (check) {

                BONKTotalSupply += originRate;
                BUSDTotalSupply -= totalExchange;
                
                BONKToken.transferFrom(msg.sender, address(this), originRate); // transfer to contract 
                BUSDToken.transfer(msg.sender, totalExchange);
                
                emit ExchangeToken(tokenAddressA, tokenAddressB, originRate, totalExchange, serviceCharge, block.timestamp);
            
            } else {
                revert("Supply is insufficient");
            }
        }
        // Case 3 : DAI -> BONK 
        else if (tokenA == DAIToken && tokenB == BONKToken) {
            
            exchangeRate = StableToBONKCalculator(originRate);
            serviceCharge = exchangeRate / interestRate;
            totalExchange = exchangeRate - serviceCharge;
            
            bool check = checkSupply(tokenB, totalExchange);
            
            if (check) {
                DAITotalSupply += originRate;
                BONKTotalSupply -= totalExchange;
                
                DAIToken.transferFrom(msg.sender, address(this), originRate); // transfer to contract
                BONKToken.transfer(msg.sender, totalExchange); // Transfer exchange to sender 
                
                emit ExchangeToken(tokenAddressA, tokenAddressB, originRate, totalExchange, serviceCharge, block.timestamp);

            } else {
                revert("Supply is insufficient");
            }
        }
        // Case 4 : BUSD -> BONK 
        else if (tokenA == BUSDToken && tokenB == BONKToken) {
            
            exchangeRate = StableToBONKCalculator(originRate);
            serviceCharge = exchangeRate / interestRate;
            totalExchange = exchangeRate - serviceCharge;
            
            bool check = checkSupply(tokenB, totalExchange); // check supply 
            
            if (check) {
                
                BUSDTotalSupply += originRate;
                BONKTotalSupply -= totalExchange;
                
                BUSDToken.transferFrom(msg.sender, address(this), originRate); // transfer to contract 
                BONKToken.transfer(msg.sender, totalExchange); // Transfer exchange amount to sender 

                emit ExchangeToken(tokenAddressA, tokenAddressB, originRate , totalExchange, serviceCharge, block.timestamp);

            } else {
                revert("Supply is insufficient");
            }
        }
        
    }

    // Withdraw 
     function withdraw(address _token, address _user, uint _amount) external onlyOwner{
        require(_amount > 0, "Withdraw amount cannot be zero");
        // Check whether it exceed supply or not
        IERC20 convert = IERC20(_token);
        if (convert == BONKToken) {
            bool overload = _amount > BONKTotalSupply;
            if (overload) {
                revert("The amount of withdraw exceed supply");
            }
            emit Withdraw(_token, _user, _amount, block.timestamp);
            BONKTotalSupply -= _amount;
            BONKToken.transfer(_user, _amount); // Transfer to said user
        } else if (convert == BUSDToken) {
            bool overload = _amount > BUSDTotalSupply;
            if (overload) {
                revert("The amount of withdraw exceed supply");
            }
            emit Withdraw(_token, _user, _amount, block.timestamp);
            BUSDTotalSupply -= _amount;
            BUSDToken.transfer(_user, _amount);
        } else if (convert == DAIToken) {
            bool overload = _amount > DAITotalSupply;
            if (overload) {
                revert("The amount of withdraw exceed supply");
            }
            emit Withdraw(_token, _user, _amount, block.timestamp);
            DAITotalSupply -= _amount;
            DAIToken.transfer(_user, _amount);
        } else {
            revert("Token's address mismatched");
        }
    }


}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}