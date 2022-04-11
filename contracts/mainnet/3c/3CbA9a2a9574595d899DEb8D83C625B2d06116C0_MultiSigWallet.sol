//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiSigWallet {
    address public constant  BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant BLST = 0x340516B933597F131E827aBdf0E3f700E24e84Ff;
    
    address public singer1 = 0x059C3d2b9c7fA47ccfee96f9bb1ba6365CD12872;
    address public singer2 = 0x8F85c1877B045B071fA3268A362d13e21622ccAc;
    address public singer3 = 0x032FF2D5535459e2A88A7F982AB7B3AED38ab6a7;

    address prevSigner;
    address token;
    uint256 amount;
    address to;
    bool isBNB;
    uint8 status; // 1 => pending, 2 => approved, 3=> rejected;
    
    constructor () {}

    modifier onlyOwners() {
        require(msg.sender==singer1||msg.sender==singer2||msg.sender==singer3);
        _;
    }

    function requestTokenTransaction(address _token, uint256 _amount, address _to) public onlyOwners {
        require(status!=1, "Current transaction is not approved or rejected");
        require(exists(_token)==true, "this is not token address");
        require(IERC20(_token).balanceOf(address(this))>=_amount, "Insufficient balance");
        prevSigner = msg.sender;
        token = _token;
        amount = _amount;
        to = _to;
        isBNB = false;
        status = 1;
    }
    function requestBNBTransaction(uint256 _amount, address _to) public onlyOwners {
        require(status!=1, "Current transaction is not approved or rejected");
        prevSigner = msg.sender;
        token = address(0);
        amount = _amount;
        to = _to;
        isBNB = true;
        status = 1;
    }
    function approveTransaction() public onlyOwners {
        require(prevSigner!=msg.sender, "You are first signer for this transaction");
        require(status==1, "This transaction was already approved or rejected (there is no requested transaction)");
        if(isBNB==true) {
            payable(to).transfer(amount);
        }else {
            IERC20(token).transfer(to, amount);
        }
        
        status = 2;
    }
    function rejectTransaction() public onlyOwners {
        require(status==1, "This transaction was already approved or rejected (there is no requested transaction)");
        status = 3;
    }

    function exists(address what)
        internal
        view
        returns (bool)
    {
        uint size;
        assembly {
            size := extcodesize(what)
        }
        return size > 0;
    }

    function compareStrings(string memory a, string memory b) internal view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    function getCurrentTranscaction() public view returns(address _prevSigner, address _token, uint256 _amount, address _to, uint8 _status, bool _isBNB) {
        return (prevSigner, token, amount, to, status, isBNB);
    }
    receive() external payable { }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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