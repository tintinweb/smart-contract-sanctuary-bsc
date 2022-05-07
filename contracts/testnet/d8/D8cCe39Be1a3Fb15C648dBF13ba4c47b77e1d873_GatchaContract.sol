/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IRandom {
    function generateLuckyNumber(uint256 _range) external view returns (uint256);
    function generateBatchLuckyNumber(uint256 _range, uint256 _rand) external view returns (uint256);
}

contract GatchaContract is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
        
    struct PrizeReference {
        IBEP20 token;
        uint256 amount; // amount of reward token, in token decimals
        uint16 totalNumber; // number of gachas
        uint16 available;   // number of available gachas
    }

    struct UserInfo {        
        mapping(IBEP20 => uint256) collected;   // amount of collect token
        mapping(IBEP20 => uint256) total;       // amount of won token
        uint8[] prizes;                         // prizes of user
    }
    
    address public prizeFundingWallet;  // to get reward token
    address public fundingWallet;       // to receive input token
    mapping(uint8 => PrizeReference) public prizeRefs;
    uint8 public prizeRefsLength = 0;
    mapping(address => UserInfo) userInfo;
    IBEP20 public inputToken;
    uint256 public price;   // in input token decimals
    IRandom public randomContract;
    mapping(IBEP20 => bool) existedRewardToken;
    IBEP20[] rewardTokens;

    event BuyGatcha(address sender, IBEP20 inputToken, uint256 price, IBEP20 token, uint256 amount, uint8 prizeRefIndex);
    event CollectReward(address user, IBEP20 token, uint256 amount);

    constructor (address _prizeFundingWallet, address _fundingWallet, IBEP20 _inputToken, uint256 _price) {        
        prizeFundingWallet = _prizeFundingWallet;
        fundingWallet = _fundingWallet;
        inputToken = _inputToken;
        price = _price;
    }

    // Set random contract. Can only be called by the owner.
    function setRandomContract(IRandom _randomContract) external onlyOwner {
      randomContract = _randomContract;
    }  

    // Set prize funding wallet. Can only be called by the owner.
    function setPrizeFundingWallet(address _prizeFundingWallet) external onlyOwner {
      prizeFundingWallet = _prizeFundingWallet;
    }

    // Set funding wallet. Can only be called by the owner.
    function setFundingWallet(address _fundingWallet) external onlyOwner {
      fundingWallet = _fundingWallet;
    }

    // Set Price. Can only be called by the owner.
    function setPrice(uint256 _price) external onlyOwner {
      price = _price;
    }

    // Set input token. Can only be called by the owner.
    function setInputToken(IBEP20 _inputToken) external onlyOwner {
      inputToken = _inputToken;
    }

    // Add a new Price Reference. Can only be called by the owner.
    function addPrizeRef(
        IBEP20 _token,
        uint256 _amount,
        uint16 _totalNumber
    ) external onlyOwner {
        prizeRefs[prizeRefsLength] = PrizeReference({
                token: _token,
                amount: _amount,
                totalNumber: _totalNumber,
                available: _totalNumber
            });
        prizeRefsLength++;
        if (!existedRewardToken[_token]) {
            rewardTokens.push(_token);
            existedRewardToken[_token] = true;
        }
    }

    // Update Price Reference.Can only be called by the owner. Shouldn't use when gatcha started.
    function updatePrizeRef(
        uint8 _index,
        IBEP20 _token,
        uint256 _amount,
        uint16 _totalNumber,
        uint16 _available
    ) external onlyOwner {
        require(_available <= _totalNumber, "Invalid input!");
        PrizeReference storage prizeRef = prizeRefs[_index];
        prizeRef.token = _token;
        prizeRef.amount = _amount;
        prizeRef.totalNumber = _totalNumber;
        prizeRef.available = _available;
        if (!existedRewardToken[_token]) {
            rewardTokens.push(_token);
            existedRewardToken[_token] = true;
        }
    }

    function viewUserPrizesLength(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        return user.prizes.length;
    }

    function viewUserPrizes(address _user, uint256 _index) external view returns (uint8) {
        UserInfo storage user = userInfo[_user];
        return user.prizes[_index];
    }

    function viewUserCollectedAmount(address _user, IBEP20 _token) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        return user.collected[_token];
    }

    function viewUserTotalAmount(address _user, IBEP20 _token) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        return user.total[_token];
    }

    function viewAvailableGatchaNumber() public view returns (uint256) {
        uint256 availableGatchaNumber;
        for (uint8 i = 0; i < prizeRefsLength; i++) {
            availableGatchaNumber += prizeRefs[i].available;
        }
        return availableGatchaNumber;
    }

    function findMatchingPrizeRefIndex(uint256 _luckyNumber) internal view returns (uint8) {
        uint256 count = 0;
        for (uint8 i = 0; i < prizeRefsLength; i++) {
            count += prizeRefs[i].available;
            if (_luckyNumber <= count && prizeRefs[i].available > 0) {
                return i;
            }
        }
        revert("No available reward!");
    }

    function buyGatcha() public nonReentrant returns (uint256) {
        uint256 availableGatchaNumber = viewAvailableGatchaNumber();
        require(availableGatchaNumber > 0, "No available gatcha!");
        inputToken.transferFrom(address(msg.sender), fundingWallet, price);
        uint256 luckyNumber = randomContract.generateLuckyNumber(availableGatchaNumber);
        uint8 prizeRefIndex = findMatchingPrizeRefIndex(luckyNumber);
        PrizeReference storage prizeRef = prizeRefs[prizeRefIndex];
        UserInfo storage user = userInfo[msg.sender];
        prizeRef.available = prizeRef.available - 1;
        user.prizes.push(prizeRefIndex);
        user.total[prizeRef.token] = user.total[prizeRef.token].add(prizeRef.amount);
        emit BuyGatcha(address(msg.sender), inputToken, price, prizeRef.token, prizeRef.amount, prizeRefIndex);

        return user.prizes.length - 1;
    }

    function batchBuyGatcha(uint256 _number) public nonReentrant returns (uint256) {
        uint256 availableGatchaNumber = viewAvailableGatchaNumber();
        require(availableGatchaNumber >= _number, "No available gatcha!");
        inputToken.transferFrom(address(msg.sender), fundingWallet, price.mul(_number));
        uint256 luckyNumber;
        uint8 prizeRefIndex;
        UserInfo storage user = userInfo[msg.sender];
        for (uint256 i = 0; i < _number; i++) {
            availableGatchaNumber = viewAvailableGatchaNumber();
            luckyNumber  = randomContract.generateBatchLuckyNumber(availableGatchaNumber, i);
            findMatchingPrizeRefIndex(luckyNumber);
            PrizeReference storage prizeRef = prizeRefs[prizeRefIndex];
            prizeRef.available = prizeRef.available - 1;
            user.prizes.push(prizeRefIndex);
            user.total[prizeRef.token] = user.total[prizeRef.token].add(prizeRef.amount);
            emit BuyGatcha(address(msg.sender), inputToken, price, prizeRef.token, prizeRef.amount, prizeRefIndex);
        }

        return user.prizes.length - _number;
    }

    function collectReward() external nonReentrant {        
        UserInfo storage user = userInfo[address(msg.sender)];
        
        for (uint8 i = 0; i < rewardTokens.length; i++) {
            uint256 pendingReward = user.total[rewardTokens[i]].sub(user.collected[rewardTokens[i]]);
            user.collected[rewardTokens[i]] = user.collected[rewardTokens[i]].add(pendingReward);
            rewardTokens[i].transferFrom(prizeFundingWallet, address(msg.sender), pendingReward);
            emit CollectReward(msg.sender, rewardTokens[i], pendingReward);
        }
    }
}