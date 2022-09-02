/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: KheeloCoinContract Mainnet.sol


pragma solidity ^0.8.16;


contract KheeloCoin is Ownable
{  
    address Auth=0x06573d15e3367D7b4a0Cb0668aEef3E2Dc074003;
    // Cards
    mapping(address => bool) BronzeCardPay;
    mapping(address => bool) SilverCardPay;
    mapping(address => bool) GoldCardPay;
    // Characters
    mapping(address => bool) NormalCharacterPay;
    mapping(address => bool) AdvanceCharacterPay;
    mapping(address => bool) NormalCharacterBorrowPay;
    mapping(address => bool) AdvanceCharacterBorrowPay;
    // Entry Fee
    mapping(address => bool) EntryFeePay;

    //Check Cost 
    modifier costs() 
    {
        EntryFeePay[msg.sender]=false;    
        //==================================================== card NFTs payment checking =============================
        
        // Bronze Card Checking
        if(msg.value==220000000000000000)//0.22 bnb
        {
            BronzeCardPay[msg.sender]=true;    
        }
        // Silver Card Checking
        if(msg.value==440000000000000000)//0.44 bnb
        {
            SilverCardPay[msg.sender]=true;    
        }
        // Gold Card Checking
        if(msg.value==660000000000000000)//0.66 bnb
        {
            GoldCardPay[msg.sender]=true;    
        }

        //==================================================== Characters NFTs payment checking =============================
        // Normal Character buy Checking
        if(msg.value==100000000000000000)//0.10 bnb
        {
            NormalCharacterPay[msg.sender]=true;    
        }
        // Advance Character buy Checking
        if(msg.value==200000000000000000)//0.20 bnb
        {
            AdvanceCharacterPay[msg.sender]=true;    
        }
        // Normal Character Borrow Checking
        if(msg.value==25000000000000000)//0.025 bnb
        {
            NormalCharacterBorrowPay[msg.sender]=true;    
        }
        // Advance Character Borrow Checking
        if(msg.value==40000000000000000)//0.040 bnb
        {
            AdvanceCharacterBorrowPay[msg.sender]=true;    
        }
        // Entry Fee Checking
        if(msg.value==50000000000000000)//0.05 bnb
        {
             EntryFeePay[msg.sender]=true;   
        }
        _;
    }
    //Special Function To Recieve Native Tokens ( BNB )
    receive() external payable costs()
    {

    }
    //Bronze Card Function
    function BronzeCard(address _user) public view returns (bool)
    {
        if (BronzeCardPay[_user] == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    //Bronze Card Verification Function
    function BronzeCardVerify(address _user) public
    {
        BronzeCardPay[_user]=false; 
    }
    
    //Silver Card Function
    function SilverCard(address _user) public view returns (bool)
    {
        if (SilverCardPay[_user] == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
     //Silver Card Verification Function
    function SilverCardVerify(address _user) public
    {
        SilverCardPay[_user]=false; 
    }

    //Gold Card Function
    function GoldCard(address _user) public view returns (bool)
    {
        if (GoldCardPay[_user] == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    //Gold Card Verification Function
    function GoldCardVerify(address _user) public
    {
        GoldCardPay[_user]=false; 
    }
    // ============================================  character ===============================
    
    //Normal Character Function
    function NormalCharacter(address _user) public view returns (bool)
    {
        if (NormalCharacterPay[_user] == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    //Advance Character Function
    function AdvanceCharacter(address _user) public view returns (bool)
    {
        if (AdvanceCharacterPay[_user] == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    //Normal Character Borrow Function
    function NormalCharacterBorrow(address _user) public view returns (bool)
    {
        if (NormalCharacterBorrowPay[_user] == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    //Advance Character Borrow Function
    function AdvanceCharacterBorrow(address _user) public view returns (bool)
    {
        if (AdvanceCharacterBorrowPay[_user] == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    // ============================================  Entry Fees ===============================
     //Entry Fee Function
    function EntryFee(address _user) public view returns (bool)
    {
        if (EntryFeePay[_user] == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    // =========================================== VERIFY SIGNATURE ===============================
    function getMessageHashUser(string memory _message) private pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked(_message));
    }
    function getMessageHashAuth(string memory _messageAuth) onlyOwner public view returns(bytes32) 
    {
        require(msg.sender==Auth, "not a valid user");
        getMessageHashUser(_messageAuth); 
        return keccak256(abi.encodePacked(_messageAuth));
    }
    function getEthSignedMessageHash(bytes32 _messageHash)public pure returns (bytes32)
    {    
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
    function verify(address _signer,string memory _message,bytes memory signature) public pure returns (bool) 
    {
        bytes32 messageHash = getMessageHashUser( _message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
       
    }
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    function splitSignature(bytes memory sig) public pure returns (bytes32 r,bytes32 s,uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly 
        {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }

    // ================================== GIVING REWARD ======================================
    
    // Check available BNB in contract
    function CheckTokenBalances() public view returns(uint256)
    {
      return address(this).balance;
    }
    // Transfer BNB to players
    function transferBNBToPlayer(uint256 amount,address _signer,string memory _message,bytes memory signature) public 
    {
        bool _sign = verify(_signer,_message,signature);
        require(_sign==true,"error");
        payable(msg.sender).transfer(amount);
    }
}