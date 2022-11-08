// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./BusdToken.sol";

/// @title Pmkn Farm
/// @author Andrew Fleming
/// @notice This contract creates a simple yield farming dApp that rewards users for
///         locking up their DAI stablecoin with a new ERC20 token PmknToken
/// @dev The inherited PmknToken contract automatically mints PMKN when the user invokes the
///      withdrawYield function. The calculateYieldTime and calculateYieldTotal function
///      takes care of all yield calculations. Ownership of the PmknToken contract should
///      be transferred to the PmknFarm contract after deployment
contract Fantasy {
    // userAddress => stakingBalance
    mapping(address => uint256) public stakingBalance;
    // userAddress => isStaking boolean
    mapping(address => bool) public isStaking;
    // userAddress => timeStamp
    mapping(address => uint256) public startTime;
    // userAddress => pmknBalance
    mapping(address => uint256) public userBalance;
    mapping(address => bool) public currentStakingStatus;

    //  mapping(string => uint256) public count;

    string public name = "Fantasy App";
    BusdToken public busdToken;
    uint256 public balance;
    address[] private stakedAddresses;
    //  uint256 private price;

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor(BusdToken _busdToken)
     // uint256 _price

    {
        // daiToken = _daiToken;
        busdToken = _busdToken;
        // price = _price;
    }

    /// @notice Locks the user's DAI within the contract
    /// @dev If the user already staked DAI, the
    /// @param amount Quantity of DAI the user wishes to lock in the contract
    function stake(uint256 amount) public {
        require(
            amount > 0 && busdToken.balanceOf(msg.sender) >= amount,
            "You cannot stake zero tokens"
        );

        if (isStaking[msg.sender] == true) {
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            userBalance[msg.sender] += toTransfer;
        }

        busdToken.transferFrom(msg.sender, address(this), amount);
        balance += amount;
        userBalance[msg.sender] += amount;
        stakingBalance[msg.sender] += amount;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        currentStakingStatus[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    /// @notice Retrieves funds locked in contract and sends them back to user
    /// @dev The yieldTransfer variable transfers the calculatedYieldTotal result to pmknBalance
    ///      in order to save the user's unrealized yield
    /// @param amount The quantity of DAI the user wishes to receive
    // function unstake(uint256 amount) public {
    //     require(
    //         isStaking[msg.sender] = true &&
    //         stakingBalance[msg.sender] >= amount,
    //         "Nothing to unstake"
    //     );
    //     uint256 yieldTransfer = calculateYieldTotal(msg.sender);
    //     startTime[msg.sender] = block.timestamp;
    //     uint256 balTransfer = amount;
    //     amount = 0;
    //     balance -= balTransfer;
    //      userBalance[msg.sender] -= balTransfer;
    //     stakingBalance[msg.sender] -= balTransfer;

    //     if(stakingBalance[msg.sender] == 0 ){
    //     busdToken.transfer(msg.sender, balTransfer);
    //     userBalance[msg.sender] += amount;
    //      stakingBalance[msg.sender] += amount;

    //         isStaking[msg.sender] = false;
    //     }
    //     emit Unstake(msg.sender, balTransfer);
    // }
    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] =
                true &&
                stakingBalance[msg.sender] >= amount,
            "Nothing to unstake"
        );
        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp;
        uint256 balTransfer = amount;
        amount = 0;
        balance -= balTransfer;
        userBalance[msg.sender] -= balTransfer;
        stakingBalance[msg.sender] -= balTransfer;
        busdToken.transfer(msg.sender, balTransfer);

        if (stakingBalance[msg.sender] == 0) {
            // userBalance[msg.sender] += yieldTransfer;
            isStaking[msg.sender] = false;
        }
        emit Unstake(msg.sender, balTransfer);
    }

    /// @notice Helper function for determining how long the user staked
    /// @dev Kept visibility public for testing
    /// @param user The user
    function calculateYieldTime(address user) public view returns (uint256) {
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    /// @notice Calculates the user's yield while using a 86400 second rate (for 100% returns in 24 hours)
    /// @dev Solidity does not compute fractions or decimals; therefore, time is multiplied by 10e18
    ///      before it's divided by the rate. rawYield thereafter divides the product back by 10e18
    /// @param user The address of the user
    function calculateYieldTotal(address user) public view returns (uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;
        uint256 rate = 86400;
        uint256 timeRate = time / rate;
        uint256 rawYield = (stakingBalance[user] * timeRate) / 10**18;
        return rawYield;
    }

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(
            toTransfer > 0 || userBalance[msg.sender] > 0,
            "Nothing to withdraw"
        );

        balance = 0;
        userBalance[msg.sender] = 0;

        stakingBalance[msg.sender] = 0;

        if (userBalance[msg.sender] != 0) {
            // balance = 0;

            // userBalance[msg.sender] = stakingBalance[msg.sender];

            //  userBalance[msg.sender] -= toTransfer;
            // stakingBalance[msg.sender] = 0;
            uint256 oldBalance = userBalance[msg.sender];

            // userBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        busdToken.transfer(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


contract BusdToken {
    string  public name = "BUSD Token";
    string  public symbol = "BUSD";
    uint256 public totalSupply = 1000000000000000000000000; // 1 million tokens
    uint8   public decimals = 18;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(){
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}