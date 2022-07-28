/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

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

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = 
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))),'TF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TF');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = 
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))),'TF');
    }

}

interface Token {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract ARTContract is Ownable {
    using TransferHelper for address;
    using SafeMath for uint256;
    using ECDSA for *;
    address public contractAddress;
    address public destroyAddress;
    Token public ART;
    Token public USDT;
    Token public ARTUSDTLP;

    uint256 public u3rate = 30;
    uint256 public u4rate = 40;
    uint256 public ulprate = 30;

    uint256 public art3rate = 30;
    uint256 public artDestroyRate = 40;
    uint256 public artlprate = 30;
    uint256 public feeRate = 1;
  
    address public uthreeAddress; // U 30%地址
    address public ufourAddress; // U 40%地址
    address public ulpAddress; // U 30%lp接收地址

    address public artthreeAddress;// ARB 30%地址
    address public artlpAddress;// ARB 30%LP地址
    address public feeAddress; //提现手续费

    address public artAddress;
    address public usdtAddress;
    address public lpAddress; //LP地址
    

    mapping(address=>mapping(uint256=>uint256)) private _depositNoce;
    mapping(address=>mapping(uint256=>uint256)) private _withdrawNoce;

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        string salt;
    }
    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,string salt)"
    );
    
    bytes32 public constant DEPOSIT_TYPEHASH = keccak256(
        "Deposit(uint256 t,uint256 level,uint256 amount,uint256 buy_level,address beneficiary,uint256 noce)"
    );

    bytes32 public constant WITHDRAW_TYPEHASH = keccak256(
        "Withdraw(uint256 t,uint256 user_id,uint256 amount,address beneficiary,uint256 itype,uint256 noce,uint256 timestamp)" 
    );

    //币种类型1USDT/2ART/3ARTUSDTLP,用户等级，币的数量，购买等级，用户地址,LP数量
    event Deposit(uint256 indexed t, uint256 level, uint256 amount, uint256 buy_level, address indexed beneficiary, uint256 indexed noce);
    //币种类型1USDT/2ART/3ARTUSDTLP,用户ID，币的数量，用户地址, 币种类型，noce
    event Withdraw(uint256 indexed t, uint256 user_id, uint256 amount, address indexed beneficiary, uint256 itype, uint256 indexed noce);
    //提币地址，数量，代币地址
    event WithdrawAdmin(address indexed recive, uint256 amount, Token indexed token);

    constructor (){
        contractAddress = address(this);
        destroyAddress = 0x000000000000000000000000000000000000dEaD;//销毁地址
        lpAddress = 0x27eafEA3bf39381466BeFDC71D9B5C6ED6FD94a2; //LP地址
        feeAddress = 0xD43b13de2cF9E141C9a4eed886aAA473AB446c70; //提现手续费地址

        artAddress = 0x77F4596aa7ECDD6Ecb7A2745D6ec02f2Dbeb79D2;//Art代币
        usdtAddress = 0x55d398326f99059fF775485246999027B3197955;//USDT代币
        uthreeAddress = 0xc3A0D9F5C2Aa951Bc34D1889809ba82B18bDD6bF;// USDT30%地址
        ufourAddress = 0x3Ee550062DAA04b25aB3fa6f0Eb7D0162b0e9989;//USDT 40%地址
        ulpAddress = 0x3449bcC760027702f79ad51806b46357eD502E2B; //USDT lp接收地址

        artthreeAddress = 0xd0949E3B71b90763234DdD5283f57940F8156d94; //ARt30%地址
        artlpAddress = 0x063b30Fa43DadE2468B469fE16b9000e6C58B806; //ART lp接收地址

        ART = Token(artAddress);
        USDT = Token(usdtAddress);
        ARTUSDTLP = Token(lpAddress);
    }

    function cashDeposit(uint256 t,uint256 level,uint256 amount,uint256 buy_level,address beneficiary,uint256 noce, bytes memory issuerSig)  public {
        _cashDepositInternal(t, level,amount,buy_level,beneficiary,noce,issuerSig);
    }  

    function cashWithdraw(uint256 t,uint256 user_id, uint256 amount, address beneficiary, uint256 itype,uint256 noce, bytes memory issuerSig, uint256 timestamp) public {
        _cashWithdrawInternal(t,user_id,amount,beneficiary,itype,noce,issuerSig,timestamp);
    }

    function _cashDepositInternal(
        uint256 t,uint256 level,uint256 amount,uint256 buy_level,address beneficiary,uint256 noce, bytes memory issuerSig
    ) internal {
        if (msg.sender != owner()) {
            require(owner() == recoverEIP712(depositHash(t,level,amount,buy_level,beneficiary,noce), issuerSig), "invalid issuer signature");
        }
        
        if (_depositNoce[beneficiary][noce]>0) {
            require(false, "repeated submit");
        }
         _depositNoce[beneficiary][noce] = amount;
        
        if (t == 1) { //USDT
            require(USDT.balanceOf(msg.sender)>=amount, "Insufficient balance");
            if(u3rate > 0){
                address(USDT).safeTransferFrom(msg.sender, uthreeAddress, amount.mul(u3rate).div(100));
            }
            if(u4rate > 0){
                address(USDT).safeTransferFrom(msg.sender, ufourAddress, amount.mul(u4rate).div(100));
            }
            if(ulprate > 0){
                uint256 ulprateNumber = amount.mul(ulprate).div(100);
                address(USDT).safeTransferFrom(msg.sender, ulpAddress,ulprateNumber);
            }
        }

        if (t == 2) { //ART
            require(ART.balanceOf(msg.sender)>=amount, "Insufficient balance");
            if(art3rate > 0){
                address(ART).safeTransferFrom(msg.sender, artthreeAddress, amount.mul(art3rate).div(100));
            }
            if(artDestroyRate > 0){
                address(ART).safeTransferFrom(msg.sender, destroyAddress, amount.mul(artDestroyRate).div(100));
            }
            if(artlprate > 0){
                uint256 arblprateNumber = amount.mul(artlprate).div(100);
                address(ART).safeTransferFrom(msg.sender, artlpAddress, arblprateNumber);
            }
        }

        if (t == 3) {
            require(ARTUSDTLP.balanceOf(msg.sender) >= amount, "Insufficient balance");
            address(ARTUSDTLP).safeTransferFrom(msg.sender, address(this), amount);
        }
        
       emit Deposit(t, level, amount, buy_level, beneficiary, noce);
    }

    function _cashWithdrawInternal(
        uint256 t,uint256 user_id, uint256 amount, address beneficiary, uint256 itype,uint256 noce, bytes memory issuerSig, uint256 timestamp
    ) internal {
        require(timestamp + 300 seconds > block.timestamp , "time out");

        require(msg.sender == beneficiary, "caller error");

        if (msg.sender != owner()) {
            require(owner() == recoverEIP712(withdrawHash(t,user_id,amount,beneficiary,itype,noce,timestamp), issuerSig),"invalid issuer signature");
        }
        if (_withdrawNoce[beneficiary][noce]>0) {
            require(false, "repeated submit");
        }

        _withdrawNoce[beneficiary][noce] = amount;

        if (t == 1) { //USDT
            require(USDT.balanceOf(address(this))>=amount, "Insufficient balance");
            if(feeRate > 0){
                address(USDT).safeTransfer(feeAddress, amount.mul(feeRate).div(100));
            }
            address(USDT).safeTransfer(beneficiary, amount.mul(uint256(100).sub(feeRate)).div(100));
        }

        if (t == 2) { //ART
            require(ART.balanceOf(address(this))>=amount, "Insufficient balance");
            if(feeRate > 0){
                address(ART).safeTransfer(feeAddress, amount.mul(feeRate).div(100));
            }
            address(ART).safeTransfer(beneficiary, amount.mul(uint256(100).sub(feeRate)).div(100));
        }

        if (t == 3) { //ARTUSDTLP
            require(ARTUSDTLP.balanceOf(address(this))>=amount, "Insufficient balance");
            if(feeRate > 0){
                address(ARTUSDTLP).safeTransfer(feeAddress, amount.mul(feeRate).div(100));
            }
            address(ARTUSDTLP).safeTransfer(beneficiary, amount.mul(uint256(100).sub(feeRate)).div(100));
        }
        
        emit Withdraw(t,user_id,amount,beneficiary,itype,noce);
    }

    // the EIP712 domain this contract uses
    function domain() internal view returns (EIP712Domain memory) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return EIP712Domain({
            name: "AR",
            version: "1.0",
            chainId: chainId,
            verifyingContract: contractAddress,
            salt: "0x43efba6b4ccb1b6faa2625fe562bdd9a23260359"
        });
    }

    // compute the EIP712 domain separator. this cannot be constant because it depends on chainId
    function domainSeparator(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {
        return keccak256(abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(eip712Domain.name)),
                keccak256(bytes(eip712Domain.version)),
                eip712Domain.chainId,
                eip712Domain.verifyingContract,
                keccak256(bytes(eip712Domain.salt))
            ));
    }

    // recover a signature with the EIP712 signing scheme
    function recoverEIP712(bytes32 hash, bytes memory sig) internal view returns (address) {
        bytes32 digest = keccak256(abi.encodePacked(
                "\x19\x01",
                domainSeparator(domain()),
                hash
            ));
        return ECDSA.recover(digest, sig);
    }

    function depositHash(uint256 t,uint256 level,uint256 amount,uint256 buy_level,address beneficiary,uint256 noce)
    internal pure returns (bytes32) {
        return keccak256(abi.encode(
                DEPOSIT_TYPEHASH,
                t,
                level,
                amount,
                buy_level,
                beneficiary,
                noce
            ));
    }


    function withdrawHash(uint256 t,uint256 user_id, uint256 amount, address beneficiary, uint256 itype,uint256 noce,uint256 timestamp)
    internal pure returns (bytes32) {
        return keccak256(abi.encode(
                WITHDRAW_TYPEHASH,
                t,
                user_id,
                amount,
                beneficiary,
                itype,
                noce,
                timestamp
            ));
    }

    function withdrawAdmin(Token token, uint256 amount, address to) public onlyOwner {
        require(token.balanceOf(address(this)) > amount, "Insufficient balance");
        address(token).safeTransfer(to, amount);
        emit WithdrawAdmin(to, amount, token);
    }

    //设置比例
    function setRate(
        uint256 u3rate_, 
        uint256 u4rate_, 
        uint256 ulprate_, 
        uint256 art3rate_,
        uint256 artDestroyRate_,
        uint256 artlprate_,
        uint256 feeRate_
    ) public onlyOwner returns (bool) {
        if(u3rate_ < 100){
            u3rate = u3rate_; 
        }
        if(u4rate_ < 100){
            u4rate = u4rate_;
        }
        if(ulprate_ < 100){
            ulprate = ulprate_;
        }

        require(u3rate + u4rate + ulprate == 100 , "urate sum not 100");

        if(art3rate_ < 100){
            art3rate = art3rate_;
        }
        if(artDestroyRate_ < 100){
            artDestroyRate = artDestroyRate_;
        }
        if(artlprate_ < 100){
            artlprate = artlprate_;
        }

        require(art3rate + artDestroyRate + artlprate == 100 , "artrate sum not 100");

        if(feeRate_ < 100){
            feeRate = feeRate_;
        }
        return true;
    }

    //设置地址
    function setAddress(
        address uthreeAddress_,
        address ufourAddress_,
        address ulpAddress_,
        address artthreeAddress_,
        address artlpAddress_,
        address feeAddress_,
        address lpAddress_
    ) public onlyOwner returns (bool) {
        if(uthreeAddress_ != address(0)){
            uthreeAddress = uthreeAddress_;
        }
        if(ufourAddress_ != address(0)){
            ufourAddress = ufourAddress_;
        }
        if(ulpAddress_ != address(0)){
            ulpAddress = ulpAddress_;
        }
        if(artthreeAddress_ != address(0)){
            artthreeAddress = artthreeAddress_;
        }
        if(artlpAddress_ != address(0)){
            artlpAddress = artlpAddress_;
        }
        if(feeAddress_ != address(0)){
            feeAddress = feeAddress_;
        }
        if(lpAddress_ != address(0)){
            lpAddress = lpAddress_;
            ARTUSDTLP = Token(lpAddress);
        }
        return true;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
}