// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/IERC20.sol';
import './interfaces/Mintable.sol';
import "./libraries/SafeMath.sol";
import './tokens/PausableToken.sol';
import './Stake.sol';
import './Ownable.sol';

contract Crowdsale is Ownable {
    using SafeMath for uint;

    // Crowdsale Stages
    enum CrowdsaleStage { SALE_NOTSTARTED, PRESALE_STAGE1, PRESALE_STAGE2, PRESALE_STAGE3, SALE }

    // Default to presale stage
    CrowdsaleStage internal stage = CrowdsaleStage.PRESALE_STAGE1;

    uint public constant MAX_STAKING_INTEREST_SUPPLY = 18000;
    uint public constant MAX_REFERRAL_SUPPLY = 2000;
    uint public constant MAX_LIQUIDITY_SUPPLY = 5000;
    uint public constant MAX_PRESALE_SLOT1_SUPPLY = 5000;
    uint public constant MAX_PRESALE_SLOT2_SUPPLY = 20000;
    uint public constant MAX_PRESALE_SLOT3_SUPPLY = 30000;
    uint public constant APY_PERCENT = 25000;

    struct StakedInfo {
        uint stakedAmount;
        uint stakedTimestamp;
        uint unstakedTimestamp;
        uint interestAmount;
        uint claimTimestamp;
    }

    // The presale token
    address public busdToken;
    // The presale token
    address public presaleToken;
    // The sale token
    address public saleToken;
    // Address where funds are collected
    address public wallet;
    // Address of Staking contract
    Stake public stakeContract;
    // Interest Supply of Sale token
    uint public stakingInterestSupply;
    // Referral Supply of Sale token
    uint public referralSupply;
    
    // How many token units a buyer gets per BUSD in wei
    uint public preSaleSlot1rate = 10000000000000;
    uint public presaleSlot1StartTime;
    uint public presaleSlot1EndTime;

    uint public preSaleSlot2rate = 15000000000000;
    uint public presaleSlot2StartTime;
    uint public presaleSlot2EndTime;

    uint public preSaleSlot3rate = 20000000000000;
    uint public presaleSlot3StartTime;
    uint public presaleSlot3EndTime;

    uint public saleStartTime;

    uint public redemptionStartTime;
    uint public redemptionEndTime;
    //Map of wallet address to array of StakedInfo of any user
    mapping(address => StakedInfo[]) internal stakedData;

    constructor(
        address _wallet,
        address _presaleToken,
        address _saleToken,
        address _busdToken,
        uint _saleStartTime
    ) {
        require(keccak256(abi.encodePacked(IERC20(_busdToken).symbol())) == keccak256(abi.encodePacked("BUSD")));
        require(_wallet != address(0));
        saleStartTime = _saleStartTime;
        presaleToken = _presaleToken;
        saleToken = _saleToken;
        busdToken = _busdToken;
        stakeContract = new Stake(_saleToken);
        wallet = _wallet;
        stakingInterestSupply = MAX_STAKING_INTEREST_SUPPLY.mul(multiplier());
        referralSupply = MAX_REFERRAL_SUPPLY.mul(multiplier());

        presaleSlot1StartTime = _saleStartTime - (21 * 24 * 60 * 60);
        presaleSlot1EndTime = presaleSlot1StartTime + (7 * 24 * 60 * 60);
        presaleSlot2StartTime = _saleStartTime - (14 * 24 * 60 * 60);
        presaleSlot2EndTime = presaleSlot2StartTime + (7 * 24 * 60 * 60);
        presaleSlot3StartTime = _saleStartTime - (7 * 24 * 60 * 60);
        presaleSlot3EndTime = presaleSlot3StartTime + (7 * 24 * 60 * 60);
        redemptionStartTime = saleStartTime;
        redemptionEndTime = redemptionStartTime + (7 * 24 * 60 * 60);
    }

    function __initialize() external onlyOwner {
        uint presaleTotalSupply = Mintable(presaleToken).initialSupply();
        uint saleTotalSupply = Mintable(saleToken).initialSupply();
        Mintable(presaleToken).mint(presaleTotalSupply);
        Mintable(saleToken).mint(saleTotalSupply);
    }

    /**
     * @dev Function to buy pre sale token in BUSD in wei
     * @param _numberOfUnits Number of pSLDRs in smallest unit to buy
     */
    function buy(uint _numberOfUnits) external {
        require(block.timestamp >= presaleSlot1StartTime, 'Presale Not started');
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        uint _rate;
        uint _soldTokens = IERC20(presaleToken).totalSupply() - IERC20(presaleToken).balanceOf(address(this));
        if(block.timestamp < presaleSlot1EndTime) {
            _rate = preSaleSlot1rate;
            require(_soldTokens + _numberOfUnits <= MAX_PRESALE_SLOT1_SUPPLY.mul(multiplier()), 'Presale Slot1 limit crossed');
        } else if(block.timestamp >= presaleSlot2StartTime && block.timestamp < presaleSlot2EndTime) {
            _rate = preSaleSlot2rate;
            require(_soldTokens + _numberOfUnits <= 
                    (MAX_PRESALE_SLOT1_SUPPLY + MAX_PRESALE_SLOT2_SUPPLY).mul(multiplier()), 'Presale Slot2 limit crossed');
        } else if(block.timestamp >= presaleSlot3StartTime && block.timestamp < presaleSlot3EndTime) {
            _rate = preSaleSlot3rate;
            require(_soldTokens + _numberOfUnits <= 
                    (MAX_PRESALE_SLOT1_SUPPLY + MAX_PRESALE_SLOT2_SUPPLY + MAX_PRESALE_SLOT3_SUPPLY).mul(multiplier()), 'Presale Slot3 limit crossed');
        }
        uint _amount = _numberOfUnits.mul(_rate);
        IERC20(busdToken).transferFrom(msg.sender, wallet, _amount);
        IERC20(presaleToken).transfer(msg.sender, _numberOfUnits);
    }
    /**
     * @dev Function to redeem pre sale token to sale token
     * @param _numberOfUnits Number of pSLDRs in smallest unit to be redeemed
     */
    function redemption(uint _numberOfUnits) external {
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        require(block.timestamp >= redemptionStartTime && block.timestamp < redemptionEndTime, 'Not in Redemption period');
        Mintable(presaleToken).burn(msg.sender, _numberOfUnits);
        IERC20(saleToken).transfer(msg.sender, _numberOfUnits);
    }
    /**
     * @dev Function to stake or deposit sale token
     * @param _numberOfUnits Number of SLDRs in smallest unit to be staked
     */
    function stakeToken(uint _numberOfUnits) external {
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        IERC20(saleToken).transferFrom(msg.sender, address(stakeContract), _numberOfUnits);
        StakedInfo memory currentStake = StakedInfo({
            stakedAmount: _numberOfUnits,
            stakedTimestamp: block.timestamp,
            unstakedTimestamp: 0,
            interestAmount: 0,
            claimTimestamp: 0
        });
        stakedData[msg.sender].push(currentStake);
    }
    /**
     * @dev Function to unstake or withdraw principal staked sale token
     */
    function unstakeToken() external {
        uint _length = stakedData[msg.sender].length;
        uint totalStakedAmount = 0;
        for(uint i=0; i< _length; i++) {
            totalStakedAmount += stakedData[msg.sender][i].stakedAmount;
            stakedData[msg.sender][i].stakedAmount = 0;
            stakedData[msg.sender][i].unstakedTimestamp = block.timestamp;
        }
        if(totalStakedAmount > 0) {
            stakeContract.unstakeToken(msg.sender, totalStakedAmount);
        }
    }
    /**
     * @dev Function to claim staked interest in sale token
     */
    function claimStakedInterest() external {
        uint _length = stakedData[msg.sender].length;
        uint totalStakedInt = 0;
        uint eachStakedInt = 0;
        uint endTimeStamp = 0;
        for(uint i=0; i< _length; i++) {
            if(stakedData[msg.sender][i].stakedAmount == 0 && stakedData[msg.sender][i].claimTimestamp >= stakedData[msg.sender][i].unstakedTimestamp) {
                continue;
            }
            eachStakedInt = 0;
            if(stakedData[msg.sender][i].unstakedTimestamp > 0) {
                endTimeStamp = stakedData[msg.sender][i].unstakedTimestamp;
            } else {
                endTimeStamp = block.timestamp;
            }

            if(stakedData[msg.sender][i].claimTimestamp == 0) {
                eachStakedInt = calculateInterestAmount(stakedData[msg.sender][i].stakedAmount, stakedData[msg.sender][i].stakedTimestamp, endTimeStamp);
            } else {
                eachStakedInt = calculateInterestAmount(stakedData[msg.sender][i].stakedAmount, stakedData[msg.sender][i].claimTimestamp, endTimeStamp);
            }

            if(stakedData[msg.sender][i].stakedAmount == 0 && // Unstake occured
                    stakedData[msg.sender][i].claimTimestamp < stakedData[msg.sender][i].unstakedTimestamp) { //But Not yet Claimed
                totalStakedInt += eachStakedInt; // Unstake occured
            } else if(stakedData[msg.sender][i].stakedAmount > 0) { //Still staked
                totalStakedInt += eachStakedInt;
            }
            stakedData[msg.sender][i].claimTimestamp = block.timestamp;
            stakedData[msg.sender][i].interestAmount += eachStakedInt;
        }
        if(totalStakedInt > stakingInterestSupply) {
            totalStakedInt = stakingInterestSupply;
        }
        if(totalStakedInt > 0) {
            stakingInterestSupply = stakingInterestSupply - totalStakedInt;
            Mintable(saleToken).burn(address(this), totalStakedInt.mul(5).div(100));
            IERC20(saleToken).transfer(msg.sender, totalStakedInt.mul(95).div(100));
        }
    }
    /**
     * @dev Function to get staked info for an address
     * @param _wallet Wallet address for which query for staking info being made
     */
    function getStakedData(address _wallet) external view returns(StakedInfo[] memory) {
        uint _length = stakedData[_wallet].length;
        StakedInfo[] memory _stakedData = new StakedInfo[](_length);
        for(uint i=0; i< _length; i++) {
            _stakedData[i] = stakedData[_wallet][i];
        }
        return _stakedData;
    }
    /**
     * @dev Function to send referral token to a given address
     * @param _to Wallet address to whome referral is sent
     * @param _amount Amount of Soldiers token to be given as referral
     */
    function referral(address _to, uint _amount) external onlyOwner {
        require(_amount <= referralSupply, 'Max Referral amount exhausted');
        referralSupply -= _amount;
        IERC20(saleToken).transfer(_to, _amount);
    }
    /**
     * @dev Function to calculate APY interest
     * @param _stakedAmount Principal amount
     * @param _startTimestamp Start timestamp
     * @param _endTimestamp End timestamp
     */
    function calculateInterestAmount(uint _stakedAmount, uint _startTimestamp, uint _endTimestamp) public view returns(uint) {
        require(_endTimestamp >=  _startTimestamp, 'End time should be after start');
        uint timeDiffinSecs = _endTimestamp - _startTimestamp;
        return _stakedAmount.mul(APY_PERCENT).div(100).mul(timeDiffinSecs).div(365 * 24 * 3600); // amount * (25000/100) * (diffOfSecs / 365 * 24 * 3600)
    }
    /**
     * @dev Function returns stage of sale at any point in time
     */
    function getStageOfSale() external view returns(CrowdsaleStage) {
        if(block.timestamp < presaleSlot1StartTime) {
            return CrowdsaleStage.SALE_NOTSTARTED;
        } else if(block.timestamp >= presaleSlot1StartTime && block.timestamp < presaleSlot1EndTime) {
            return CrowdsaleStage.PRESALE_STAGE1;
        } else if(block.timestamp >= presaleSlot2StartTime && block.timestamp < presaleSlot2EndTime) {
            return CrowdsaleStage.PRESALE_STAGE2;
        } else if(block.timestamp >= presaleSlot3StartTime && block.timestamp < presaleSlot3EndTime) {
            return CrowdsaleStage.PRESALE_STAGE3;
        } else if(block.timestamp >= saleStartTime) {
            return CrowdsaleStage.SALE;
        }
    }
    /**
     * @dev Function to pause or unpause presale token
     * @param _value Boolean value True to pause and False to unpause
     */
    function pausePresaleToken(bool _value) public onlyOwner {
        if(_value) {
            PausableToken(presaleToken).pause();
        } else {
            PausableToken(presaleToken).unpause();
        }
    }
    /**
     * @dev Function to pause or unpause sale token
     * @param _value Boolean value True to pause and False to unpause
     */
    function pauseSaleToken(bool _value) public onlyOwner {
        if(_value) {
            PausableToken(saleToken).pause();
        } else {
            PausableToken(saleToken).unpause();
        }
    }
    /**
     * @dev Function to set sale start time
     * @param _saleStartTimestamp sale start time
     */
    function setSaleStartTime(uint _saleStartTimestamp) public onlyOwner {
        saleStartTime = _saleStartTimestamp;
    }
    /**
     * @dev Function to set pre sale slot1 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot1Rate(uint _rate) public onlyOwner {
        require(_rate > 0, 'Presale Slot1 Rate is 0');
        preSaleSlot1rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot1 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setPreSaleSlot1Window(uint _daysPrior, uint _durationInSecs) public onlyOwner {
        presaleSlot1StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot1EndTime = presaleSlot1StartTime + _durationInSecs;
        require(presaleSlot1EndTime <= presaleSlot2StartTime, 'Presale Slot1 end time greater than slot2 start time');
    }
    /**
     * @dev Function to set pre sale slot1 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot2Rate(uint _rate) public onlyOwner {
        require(_rate > 0, 'Presale Slot2 Rate is 0');
        preSaleSlot2rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot2 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setPreSaleSlot2Window(uint _daysPrior, uint _durationInSecs) public onlyOwner {
        presaleSlot2StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot2EndTime = presaleSlot2StartTime + _durationInSecs;
        require(presaleSlot2EndTime <= presaleSlot3StartTime, 'Presale slot2 end time greater than slot3 start time');
    }
    /**
     * @dev Function to set public presale or slot3 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot3Rate(uint _rate) public onlyOwner {
        require(_rate > 0, 'Presale Slot2 Rate is 0');
        preSaleSlot3rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot3 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot3 start time
     */
    function setPreSaleSlot3Window(uint _daysPrior, uint _durationInSecs) public onlyOwner {
        presaleSlot3StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot3EndTime = presaleSlot3StartTime + _durationInSecs;
        require(presaleSlot3EndTime <= saleStartTime, 'Presale Slot3 end time greater than sale time');
    }
    /**
     * @dev Function to set pre-sale slot2 window w.r.t sale start time
     * @param _daysAfter number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setRedemptionWindow(uint _daysAfter, uint _durationInSecs) public onlyOwner {
        redemptionStartTime = saleStartTime + (_daysAfter * 24 * 60 * 60);
        redemptionEndTime = redemptionStartTime + _durationInSecs;
    }

    function multiplier() internal view returns(uint) {
        return 10**IERC20(saleToken).decimals();
    }


}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface Mintable {
    function initialSupply() external returns(uint);
    function mint(uint _amount) external returns (bool);
    function burn(address _holder, uint _amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint) {
        uint c = a / b;
        return c;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./BasicToken.sol";
import '../Ownable.sol';

abstract contract PausableToken is BasicToken, Ownable {

    event Pause();
    event Unpause();
    bool public paused = false;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!isPaused(), 'Token Paused');
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(isPaused(), 'Token Not Paused');
        _;
    }
    /**
     * @dev Returns true if the Token is paused.
     */
    function isPaused() public view returns (bool) {
        return paused;
    }
    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyOwner whenNotPaused external {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyOwner whenPaused external {
        paused = false;
        emit Unpause();
    }

    function transfer(address _to, uint _value) public override virtual whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public override virtual whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public override virtual whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/IERC20.sol';
import './Ownable.sol';

contract Stake is Ownable {
    
    // The sale token
    address public saleToken;

    constructor(address _saleToken) {
        saleToken = _saleToken;
    }

    function unstakeToken(address _to, uint unstakeAmount) public onlyOwner {
        require(unstakeAmount <= IERC20(saleToken).balanceOf(address(this)), 'Insufficient balance');
        IERC20(saleToken).transfer(_to, unstakeAmount);
    }

    function multiplier() internal view returns(uint) {
        return 10**IERC20(saleToken).decimals();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '../interfaces/IERC20.sol';
import "../libraries/SafeMath.sol";

abstract contract BasicToken is IERC20 {
    using SafeMath for uint;

    uint constant MAX = ~uint256(0);

    uint public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;
   
   /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint _value) public override virtual returns (bool) {
        require(_spender != address(0), "Approve to the invalid or zero address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

   /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public override virtual returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

   /**
    * The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf. 
    * This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in sub-currencies. 
    * The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism.
    * @param _from address which you want to send tokens from
    * @param _to address which you want to transfer to
    * @param _value uint the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint _value) public override virtual returns (bool success) {
        require(_from != address(0), "Invalid Sender Address");
        require(allowance[_from][msg.sender] >= _value, "Transfer amount exceeds allowance");
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        return true;
    }

   /**
    * Internal method that does transfer token from one account to another
    */
    function _transfer(address _sender, address _recipient, uint _amount) internal {
        require(_sender != address(0), "Invalid Sender Address");
        require(_recipient != address(0), "Invalid Recipient Address");
        
        uint balanceAmt = balanceOf[_sender];
        require(balanceAmt >= _amount, "Transfer amount exceeds balance of sender");
        require(_amount <= MAX - balanceOf[_recipient], "Balance limit exceeded for Recipient.");
        
        balanceOf[_sender] = balanceAmt.sub(_amount);
        balanceOf[_recipient] = balanceOf[_recipient].add(_amount);
        
        emit Transfer(_sender, _recipient, _amount);
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function _mint(address _to, uint _amount) internal returns (bool) {
        require(_to != address(0), "mint to the zero address");
        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _holder The address from which tokens to be burned.
    * @param _value The amount of token to be burned.
    */
    function _burn(address _holder, uint _value) internal returns (bool) {
        require(_holder != address(0), "Burn from the zero address");
        require(_value <= balanceOf[_holder], 'Burn amount exceeds balance of holder');

        balanceOf[_holder] = balanceOf[_holder].sub(_value);
        require(_value <= totalSupply, "Insufficient total supply.");
        totalSupply = totalSupply.sub(_value);
        emit Transfer(_holder, address(0), _value);
        return true;
    }
}