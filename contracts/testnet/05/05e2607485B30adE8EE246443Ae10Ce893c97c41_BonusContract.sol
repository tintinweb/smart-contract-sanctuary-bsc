/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT

// File: contracts/lib/ECDSA.sol

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: contracts/lib/SafeMath.sol


pragma solidity >=0.6.4 <0.8.0;

/**
 * Copyright (c) 2016-2019 zOS Global Limited
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/lib/IBEP20.sol


pragma solidity >=0.6.4 <0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
// File: contracts/lib/TransferHelper.sol


pragma solidity >=0.6.4 <0.8.0;



library TransferHelper {
    using SafeMath for uint256;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            address(token).call(
                abi.encodeWithSelector(token.transfer.selector, to, value)
            );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            address(token).call(
                abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
            );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);

        (bool success, bytes memory data) =
            address(token).call(
                abi.encodeWithSelector(token.approve.selector,spender,newAllowance)
            );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "INCREASE_ALLOWANCE_FAILED"
        );     
    }
}
// File: contracts/BonusContract.sol


/*
https://dars.one/
*/
pragma solidity 0.7.6;

pragma experimental ABIEncoderV2;

contract BonusContract{

    using SafeMath for uint256;
    using ECDSA for bytes32;
    using TransferHelper for IBEP20;

    struct User {
        uint128 id;
        uint128 bonusNonce;
        uint256 totalBuy;
        uint256 totalBuyOutside;
        uint256 totalBuySpecial;
        uint256 affectedBuySpecial;
        uint256 totalUpgrade;
        uint256 totalBonus;  
    }

    struct Packet{
        uint256 id;
        uint256 packetType;
        uint256 qty;
        uint256 packetPrice;
        address target;
        bool upgradable;
        bool affecting;
        bool cartDependent;
    }
    mapping(bytes32=>Packet) private packets;
    mapping(address=>bool) public migrated;
    bytes32[] private allPackets;
    
    IBEP20 immutable public bonusToken;
    address immutable public darsBasis;
    uint256 immutable public chainId;
    uint256 immutable public darsPercent;
    address immutable public companyOwner;
    address immutable public darsSigner;
    address public companySigner;
    address public migrationsAdmin;
    uint256 public bonusPercent;
    address public companyContract;
    string  public darsName;
    string  public Url;  
    uint128 public lastUserId = 0;
    uint128 public lastPacketId = 0;
    bool public lowBalance = false;
    bool public salesStopped = false;
    uint256 public totalWithdrawBonus;
    uint256 public totalBuy;
    uint256 public totalBuyOutside;
    uint256 public totalBuySpecial;
    uint256 public totalUpgrade;
    uint256 public lastWithdrawalTimestamp;
    uint256 constant public maxTermWithoutCompanySignature = 15552000;//180 days

    

    mapping(address => User) public users;
    mapping(uint128 => address) private usersID;
    
    modifier onlyCompanyOwner() {
        require(companyOwner == msg.sender, "caller is not the owner");
        _;
    }

    modifier onlyDarsSigner() {
        require(darsSigner == msg.sender, "caller is not darsSigner");
        _;
    }


    event PacketAdded(uint256 id,
                uint256 packetType,
                uint256 qty,
                uint256 packetPrice,
                address targetContract,
                bytes32 singlePacketUID,
                bool upgradeable,
                bool affecting,
                bool cartDependent);

    event PacketUpdated(uint256 id,
                uint256 qty,
                uint256 packetPrice,
                address targetContract,
                bytes32 singlePacketUID,
                bool upgradeable,
                bool affecting,
                bool cartDependent);

    event Migrations(address user, 
                    uint256 totalBuy,
                    uint256 totalBuyOutside,
                    uint256 totalBuySpecial,
                    uint256 affectedBuySpecial,
                    uint256 totalUpgrade);

    event Withdraw(address user, uint256 amount,uint128 nextnonce);
    event Registration(address user, uint128 userId);
    event Buy(address user,uint256 price,bytes32 orderUID);
    event BuyOutside(address user,uint256 price,uint256 marketing);
    event BuySpecial(address user,uint256 price,bytes32 singlePacketUID);
    event UpgradeSpecial(address user,uint256 price,bytes32 singlePacketUID);

    constructor(address _companyOwner,
                address _companySigner,
                address _darsSigner,
                address _companyContract,
                address _bonusToken,
                uint256 _darsPercent,
                uint256 _bonusPercent,
                string memory _darsName, 
                string memory _Url) {

        darsBasis = 0x1adb10754112aaAb5EB91bc6e772d82352C9C66f; //msg.sender;//parent, Dars platform base contract
        companyOwner = _companyOwner;
        darsSigner = _darsSigner;
        companySigner = _companySigner;
        companyContract = _companyContract;
        darsName = _darsName;
        Url = _Url;
        bonusPercent = _bonusPercent;
        darsPercent = _darsPercent;
        bonusToken=IBEP20(_bonusToken);
        uint256 _chainId;
        assembly {
            _chainId := chainid()
        }
        chainId=_chainId;
        lastWithdrawalTimestamp=block.timestamp;
    }

    function antiSabotage(bool _lowBalance) external onlyDarsSigner {
       lowBalance=_lowBalance; 
    }

    function withdrawBonus(uint256 amount, bytes calldata signatureDars,bytes calldata signatureCompany) external {
        uint128 id=users[msg.sender].id;
        require(id>0,"The user doesn't exist!");
        require(amount>0,"bonus must be greater than 0");
        bytes32 hash=createHash(id,amount,users[msg.sender].bonusNonce);
        hash=hash.toEthSignedMessageHash();
        require(hash.recover(signatureDars)==darsSigner,"dars signature is wrong");
        bool isSolvent=bonusToken.balanceOf(address(this))>=amount;
        
        if((block.timestamp-lastWithdrawalTimestamp)<maxTermWithoutCompanySignature){
            require(hash.recover(signatureCompany)==companySigner,"company signature is wrong");
            lastWithdrawalTimestamp=block.timestamp;
        }else{
            salesStopped=true;
        }
        
        if(isSolvent){
            users[msg.sender].bonusNonce++;
            users[msg.sender].totalBonus=users[msg.sender].totalBonus.add(amount);
            totalWithdrawBonus=totalWithdrawBonus.add(amount);
            lowBalance=false;                     
            bonusToken.safeTransfer(address(msg.sender), amount);
            emit Withdraw(msg.sender,amount,users[msg.sender].bonusNonce);
        }else{
            require(lowBalance==false,"low contract balance..Please contact to support of company.");
            lowBalance=true;
        }

    }


    function dbMigrations(address _user,
                        uint256 _totalBuy,
                        uint256 _totalBuyOutside,
                        uint256 _totalBuySpecial,
                        uint256 _affectedBuySpecial,
                        uint256 _totalUpgrade) external {
        
        require(migrationsAdmin==msg.sender,"this caller is not a migration admin");
        require(migrated[_user]==false,"this user already migrated");                    
        if(users[_user].id==0){
            _registration(_user);
        }
        migrated[_user]=true;
        User storage user = users[_user];
        user.totalBuy=user.totalBuy.add(_totalBuy);
        user.totalBuyOutside=user.totalBuyOutside.add(_totalBuyOutside);
        user.totalBuySpecial=user.totalBuySpecial.add(_totalBuySpecial);
        user.affectedBuySpecial=user.affectedBuySpecial.add(_affectedBuySpecial);
        user.totalUpgrade=user.totalUpgrade.add(_totalUpgrade);
        
        emit Migrations(_user, 
                    user.totalBuy,
                    user.totalBuyOutside,
                    user.totalBuySpecial,
                    user.affectedBuySpecial,
                    user.totalUpgrade);

    }

    function _registration(address newUser) internal {

        User memory user = User({
            id: ++lastUserId,
            bonusNonce: uint128(0),
            totalBuy: 0,
            totalBuyOutside:0,
            totalBuySpecial: 0,
            affectedBuySpecial:0,
            totalUpgrade:0,
            totalBonus: 0
        });
        users[newUser] = user;
        usersID[lastUserId]=newUser;
        emit Registration(newUser, lastUserId);

    } 

    function _buy(address payer,uint256 price) internal {
        
        require(price > 0, "price must be greater than 0");
        require(!lowBalance, "operations suspended, low balance for bonuses");
        require(!salesStopped, "this company under liquidation, the sale is stopped");
        require(
            bonusToken.allowance(payer, address(this)) >=
                price,
            "Increase the allowance first,call the approve method"
        );
        
        bonusToken.safeTransferFrom(
            payer,
            address(this),
            price
        );
        uint256 toDarsAmount=price.mul(darsPercent).div(100);
        uint256 toBonusAmount=price.mul(bonusPercent).div(100);
        uint256 toCompanyAmount=price.sub(toDarsAmount.add(toBonusAmount));
        
        if(toDarsAmount>0){
            bonusToken.safeTransfer(darsBasis, toDarsAmount);
        }

        if(toCompanyAmount>0){
            bonusToken.safeTransfer(companyContract, toCompanyAmount);
        }

    }

    //marketing 0-DEFAULT
    function buyOutside(address user,uint256 price,uint256 marketing) external {
        require(users[user].id>0,"user not exist");
        _buy(msg.sender,price);
        totalBuyOutside=totalBuyOutside.add(price);       
        users[user].totalBuyOutside=users[user].totalBuyOutside.add(price);
        emit BuyOutside(user,price,marketing);
    }

    function buy(uint256 price,bytes32 orderUID) external {
        _buy(msg.sender,price);
        if(users[msg.sender].id==0){
            _registration(msg.sender);
        }
        totalBuy=totalBuy.add(price);       
        users[msg.sender].totalBuy=users[msg.sender].totalBuy.add(price);
        emit Buy(msg.sender,price,orderUID);
    }

    function buySpecial(uint256 price,bytes32 singlePacketUID) external {

        require(price > 0 && packets[singlePacketUID].packetPrice==price,"bad packet price or packet not avaible");
        _buy(msg.sender,price); 
        if(users[msg.sender].id==0){
            _registration(msg.sender);
        }
        totalBuySpecial=totalBuySpecial.add(price);
        users[msg.sender].totalBuySpecial=users[msg.sender].totalBuySpecial.add(price);

        if(packets[singlePacketUID].affecting){
            users[msg.sender].affectedBuySpecial=users[msg.sender].affectedBuySpecial.add(price);
        }

        if(packets[singlePacketUID].target!=address(0)){
            (bool success,) = packets[singlePacketUID].target
            .call(abi.encodeWithSignature("delivery(address,uint256,uint256,uint256,uint256)",
            msg.sender,packets[singlePacketUID].packetType,packets[singlePacketUID].qty,packets[singlePacketUID].id,price));
            require(success,"delivery call FAIL");
        }
        
        emit BuySpecial(msg.sender,price,singlePacketUID);
    }

    function upgradeSpecial(uint256 maxPrice,bytes32 singlePacketUID) external {
        require(users[msg.sender].id>0,"user not exist");

        (bool success,uint256 price) = getUpgradePriceIfAvailable(msg.sender,singlePacketUID);
        require(success,"This upgrade is not available");
        require(price <= maxPrice,"bad upgrade price, maybe the packet price was changed");
        _buy(msg.sender,price);
        totalUpgrade=totalUpgrade.add(price);
        users[msg.sender].totalUpgrade=users[msg.sender].totalUpgrade.add(price);
        
        if(packets[singlePacketUID].affecting){
            users[msg.sender].affectedBuySpecial=users[msg.sender].affectedBuySpecial.add(price);
        }      

        if(packets[singlePacketUID].target!=address(0)){
            (success,) = packets[singlePacketUID].target
            .call(abi.encodeWithSignature("upgradeDelivery(address,uint256,uint256,uint256,uint256)",
            msg.sender,packets[singlePacketUID].packetType,packets[singlePacketUID].qty,packets[singlePacketUID].id,price));
            require(success,"upgradeDelivery call FAIL");
        }
        
        emit UpgradeSpecial(msg.sender,price,singlePacketUID);

    }

    function getUpgradePriceIfAvailable(address user,bytes32 singlePacketUID) public view returns (bool,uint256) {

        if(users[user].id > 0 && packets[singlePacketUID].packetPrice>0 && packets[singlePacketUID].upgradable){
            uint256 affected=users[user].affectedBuySpecial;
            if(packets[singlePacketUID].cartDependent){
                affected = affected.add(users[user].totalBuy).add(users[user].totalBuyOutside);
            }
            if(packets[singlePacketUID].packetPrice>affected){
                return (true,packets[singlePacketUID].packetPrice.sub(affected)); 
            }
        }
        return (false,0);
    }

    function getPacketsList() public view returns (bytes32[] memory) {
        return allPackets;
    }

    function uidToId(bytes32 singlePacketUID) external view returns (uint256){
        return packets[singlePacketUID].id;
    }

    function getPacketByUID(bytes32 singlePacketUID) external view returns (Packet memory){
        
        return packets[singlePacketUID];
    }

    function getPacketByID(uint256 packetId) external view returns (Packet memory){
        require(packetId > 0 && packetId <= lastPacketId, "wrong Id");
        bytes32 id = allPackets[packetId-1];
        return packets[id];
    }

    function isPacketActive(bytes32 singlePacketUID) external view returns(bool){
        return (packets[singlePacketUID].target != address(0));
    } 

    function createHash(uint128 to, uint256 amount, uint128 nonce) internal view returns (bytes32)
    {
        return keccak256(abi.encodePacked(chainId, this, to, amount, nonce));
    }
    
    function isUserExists(address user) external view returns (bool) {
        return (users[user].id > 0);
    }

    function getUserNonce(address user) external view returns (uint128) {
        return users[user].bonusNonce;
    }

    function addressToId(address user) external view returns (uint128) {
        require(users[user].id>0,"The user doesn't exist!");
        return users[user].id;
    }

    function idToAddress(uint128 id) external view returns (address) {
        require(id>0 && id<=lastUserId,"The user doesn't exist!");
        return usersID[id];
    }
    /*
        TYPE_PACKAGE = 1;
        TYPE_ACTIVITY = 2;
        TYPE_ONE_TIME_FEE = 3;
    */
    function addPacket(uint256 _qty,
                    uint256 _packetType,
                    uint256 _packetPrice, 
                    address _target,
                    bytes32 singlePacketUID,
                    bool _upgradable,
                    bool _affecting,
                    bool _cartDependent) external onlyCompanyOwner {
        
        if(_target!=address(0)){
            uint32 size;
            assembly {
                size := extcodesize(_target)
            }
            require(size != 0, "The target must be a contract or zero address");
        }
        

        if(packets[singlePacketUID].id>0){
            require(packets[singlePacketUID].packetType==_packetType,"type change not available");
            packets[singlePacketUID].qty=_qty;
            packets[singlePacketUID].packetPrice=_packetPrice;
            packets[singlePacketUID].target=_target;
            packets[singlePacketUID].upgradable=_upgradable;
            packets[singlePacketUID].affecting=_affecting;
            packets[singlePacketUID].cartDependent=_cartDependent;
            emit PacketUpdated(packets[singlePacketUID].id,_qty,_packetPrice, _target, singlePacketUID,_upgradable,_affecting,_cartDependent);
        }else{
            packets[singlePacketUID]=Packet(
            {id:++lastPacketId,
            packetType:_packetType,
            qty:_qty,
            packetPrice:_packetPrice,
            target:_target,
            upgradable:_upgradable,
            affecting:_affecting,
            cartDependent:_cartDependent
            });
            allPackets.push(singlePacketUID);
            emit PacketAdded(lastPacketId,_packetType,_qty,_packetPrice, _target, singlePacketUID,_upgradable,_affecting,_cartDependent);
        }
        
    }

    function setMigrationsAdmin(address _migrationsAdmin) external onlyCompanyOwner {
        migrationsAdmin = _migrationsAdmin;
    }

    function setBonusPercent(uint256 newPercent) external onlyCompanyOwner {
        require(newPercent>0 && newPercent <= uint256(100).sub(darsPercent),"bad percent");
        bonusPercent = newPercent;
    }
    
    function setCompanyUrl(string calldata _Url) external onlyCompanyOwner {
        Url = _Url;
    }
    function setCompanyContract(address _companyContract) external onlyCompanyOwner {
        companyContract = _companyContract;
    }

    function setCompanySigner(address _companySigner) external onlyCompanyOwner {
        companySigner = _companySigner;
    }
}