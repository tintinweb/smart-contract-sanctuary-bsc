/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}


interface IPresale {
    function allocation(address user) view external returns (uint256);
    function contributed(address user) view external returns (uint256);
}

contract Presale is Ownable {
    address public TREASURY;
    address public BASE;
    address public TOKEN;
    IPresale public PRESALEV1;

    bool public claimActive = false;
    bool public refundActive = false;

    mapping(address => bool) public claimed;
    mapping(address => bool) public refunded;

    constructor(
        address _TREASURY,
        address _BASE,
        address _TOKEN,
        address _PRESALEV1
    ) {
        TREASURY = _TREASURY;
        BASE = _BASE;
        TOKEN = _TOKEN;
        PRESALEV1 = IPresale(_PRESALEV1);
    }

    function allocation(address user) view public returns (uint256) {
        return PRESALEV1.allocation(user);
    }

    function contributed(address user) view external returns (uint256) {
        return PRESALEV1.contributed(user);
    }

    function changeToken(address _TOKEN) public onlyOwner {
        TOKEN = _TOKEN;
    }

    function toggleClaim(bool value) external onlyOwner {
        claimActive = value;
    }

    function toggleRefund(bool value) external onlyOwner {
        refundActive = value;
    }

    function withdrawToken(address _token) external onlyOwner {
        if (IERC20(_token).balanceOf(address(this)) > 0) {
            IERC20(_token).transfer(
                TREASURY,
                IERC20(_token).balanceOf(address(this))
            );
        }
    }

    function claim() external {
        require(claimActive, "CLAIM: Claiming is not active yet.");
        require(!claimed[msg.sender], "CLAIM: Already claimed.");
        uint256 amountOfTokens = PRESALEV1.allocation(msg.sender);
        require(
            IERC20(TOKEN).balanceOf(TREASURY) >= amountOfTokens,
            "CLAIM: Please contact dev."
        );

        claimed[msg.sender] = true;
        IERC20(TOKEN).transferFrom(TREASURY, msg.sender, amountOfTokens);
    }

    function refund() external {
        require(refundActive, "REFUND: Refunding is not active yet.");
        require(!refunded[msg.sender], "REFUND: Already refunded.");
        uint256 amountOfBase = PRESALEV1.contributed(msg.sender);
        require(
            IERC20(BASE).balanceOf(TREASURY) >= amountOfBase,
            "REFUND: Please contact dev."
        );

        refunded[msg.sender] = true;
        IERC20(BASE).transferFrom(TREASURY, msg.sender, amountOfBase);
    }

    function getInfo()
        external
        view
        returns (
            bool,
            bool
        )
    {
        return (
            claimActive,
            refundActive
        );
    }
}