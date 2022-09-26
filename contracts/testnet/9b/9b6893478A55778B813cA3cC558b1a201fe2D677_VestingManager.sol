//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract VestingManager is ReentrancyGuard {  

    IERC20 private masterToken;
    address public manager;
    address[] public whitelistAddresses;

    mapping(address => bool) public isWhitelist;

    struct VestingInfo {
        uint256 paymentList;
        uint256 amount;
        bool ispaymentSuccess;
    }
    VestingInfo[] public paymentList;

    modifier onlyManager() {
        require(msg.sender == manager, "only manager can execute this action");
        _;
    }

    function initpaymentList() internal {
        VestingInfo memory unlockTGE = VestingInfo(1663606800,1000000 * 10**6,false);//20/09/2022,
        VestingInfo memory unlock_2023Mar29 = VestingInfo(1680022800,350000 * 10**6,false);//29/03/2023,
        VestingInfo memory unlock_2023Apr28 = VestingInfo(1682614800,350000 * 10**6,false);//28/04/2023,
        VestingInfo memory unlock_2023May28 = VestingInfo(1685206800,350000 * 10**6,false);//28/05/2023,
        VestingInfo memory unlock_2023Jun27 = VestingInfo(1687798800,350000 * 10**6,false);//27/06/2023,
        VestingInfo memory unlock_2023Jul27 = VestingInfo(1690390800,350000 * 10**6,false);//27/07/2023,
        VestingInfo memory unlock_2023Aug26 = VestingInfo(1692982800,350000 * 10**6,false);//26/08/2023,
        VestingInfo memory unlock_2023Sep25 = VestingInfo(1695574800,350000 * 10**6,false);//25/09/2023,
        VestingInfo memory unlock_2023Oct25 = VestingInfo(1698166800,350000 * 10**6,false);//25/10/2023,
        VestingInfo memory unlock_2023Nov24 = VestingInfo(1700758800,350000 * 10**6,false);//24/11/2023,
        VestingInfo memory unlock_2023Dec24 = VestingInfo(1703350800,350000 * 10**6,false);//24/12/2023,
        VestingInfo memory unlock_2024Jan23 = VestingInfo(1705942800,350000 * 10**6,false);//23/01/2024,
        VestingInfo memory unlock_2024Feb22 = VestingInfo(1708534800,150000 * 10**6,false);//22/02/2024,
        //=======================================================================,
        paymentList.push(unlockTGE);//20/09/2022,
        paymentList.push(unlock_2023Mar29);//29/03/2023,
        paymentList.push(unlock_2023Apr28);//28/04/2023,
        paymentList.push(unlock_2023May28);//28/05/2023,
        paymentList.push(unlock_2023Jun27);//27/06/2023,
        paymentList.push(unlock_2023Jul27);//27/07/2023,
        paymentList.push(unlock_2023Aug26);//26/08/2023,
        paymentList.push(unlock_2023Sep25);//25/09/2023,
        paymentList.push(unlock_2023Oct25);//25/10/2023,
        paymentList.push(unlock_2023Nov24);//24/11/2023,
        paymentList.push(unlock_2023Dec24);//24/12/2023,
        paymentList.push(unlock_2024Jan23);//23/01/2024,
        paymentList.push(unlock_2024Feb22);//22/02/2024
    }

    constructor(address _token, address _managerAddress) {
        require(_token != address(0), 'invalid token address');
        require(_managerAddress != address(0), 'invalid manager address');
        require(_token != _managerAddress, 'token address must be different from manager address');
        masterToken = IERC20(_token);
        manager = _managerAddress;
        initpaymentList();
    }

    function setWhitelist(address[] memory _whitelist) external onlyManager {
        for (uint256 index = 0; index < _whitelist.length; index++) {     
            address tempUser = _whitelist[index];      
            require(tempUser != address(0), "invalid whitelist user"); 
            require(isWhitelist[tempUser] == false, "each address in whitelist address must be unique");       
            isWhitelist[tempUser] = true;
        }
        whitelistAddresses = _whitelist;
    }

    function getTotalAmount() public view returns (uint256) {   
        uint256 totalAmount = 0;
        for (uint256 index = 0; index < paymentList.length; index++) {
            VestingInfo storage itemPayment = paymentList[index];
            totalAmount =  totalAmount + itemPayment.amount;
        }
        return totalAmount;
    }
    
    function deposit() external payable onlyManager {
        uint256 totalAmountNeeded = getTotalAmount();
        require(totalAmountNeeded > 0, "need to init paymentList first");
        require(masterToken.balanceOf(msg.sender) >= totalAmountNeeded, "insufficient account balance");
        masterToken.transferFrom(msg.sender, address(this), totalAmountNeeded);
    }   

    function makePayment() external payable nonReentrant onlyManager {        
        uint256 paymentAmount = 0;
        uint currentTime = block.timestamp;
        for (uint256 index = 0; index < paymentList.length; index++) {
            VestingInfo storage itemPayment = paymentList[index];
            if (itemPayment.ispaymentSuccess == false && itemPayment.paymentList <= currentTime) 
            {
                paymentAmount += itemPayment.amount;
                itemPayment.ispaymentSuccess = true;
            }
        }
        require(paymentAmount > 0, "payment amount is zero");
        require(masterToken.balanceOf(address(this)) >= paymentAmount, "insufficient account balance");
        //send the token for each address in whitelist addresses
        require(whitelistAddresses.length > 0, "whitelist cannot be null");
        uint256 pieceForOne =  paymentAmount / (whitelistAddresses.length);
        require(pieceForOne > 0, "piece amount must be large than zero");
        for (uint256 index = 0; index < whitelistAddresses.length; index++) {            
            masterToken.transfer(whitelistAddresses[index], pieceForOne);
        }        
    }

     receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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