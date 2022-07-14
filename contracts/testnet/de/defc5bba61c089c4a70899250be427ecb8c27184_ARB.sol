/**
 *Submitted for verification at BscScan.com on 2022-07-14
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

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

contract ARB is Ownable {
    using TransferHelper for address;
    using SafeMath for uint256;
    using ECDSA for *;
    address public contractAddress;
    address public pancakeRoute2Address;
    address public destroyAddress;//销毁地址
    Token public AR;
    Token public USDT;
    Token public ARUSDTLP;

    uint256 public remainArb;
    uint256 public remainUsdt;
    uint256 public u3rate = 30; //U报单比例30%
    uint256 public u4rate = 40; //U报单比例 40%
    uint256 public ulprate = 30; // U加lp比例 30%

    uint256 public arb3rate = 30; // ARB 报单比例
    uint256 public arbDestroyRate = 40; //ARB报单销毁比例 40%
    uint256 public arblprate = 30; // U加lp比例 30%
    uint256 public feeRate = 1;// 提现手续费比例
  
    address public uthreeAddress; // U 30%地址
    address public ufourAddress; // U 40%地址
    address public ulpAddress; // U 30%lp接收地址

    address public arbthreeAddress;// ARB 30%地址
    address public arblpAddress;// ARB 30%LP地址
    address public feeAddress; //提现手续费

    address public arbAddress;
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

    //币种类型1USDT/2AR/3ARUSDTLP,用户等级，币的数量，购买等级，用户地址,LP数量
    event Deposit(uint256 indexed t, uint256 level, uint256 amount, uint256 buy_level, address indexed beneficiary, uint256 indexed noce,uint256 lpAmount);
    //币种类型1USDT/2AR/3ARUSDTLP,用户ID，币的数量，用户地址, 币种类型，noce
    event Withdraw(uint256 indexed t, uint256 user_id, uint256 amount, address indexed beneficiary, uint256 itype, uint256 indexed noce);
    //提币地址，数量，代币地址
    event WithdrawAdmin(address indexed recive, uint256 amount, Token indexed token);

    constructor (){
        contractAddress = address(this);
        destroyAddress = 0x000000000000000000000000000000000000dEaD;//销毁地址
        lpAddress = 0xa8f995c421dd784ec328618f84196574255A43ea; //LP地址
        feeAddress = 0xd5AA2d895Eb849EA0eAbfC6fED2aF00760B4F59a; //提现手续费地址
        pancakeRoute2Address = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // pancakeroute2

        arbAddress = 0x320B77A5874aeA0E068e2456aCAf5eFd9CCA33eC;//ARB代币
        usdtAddress = 0xC8ed57258796052f9A3728391B8451bBBAa217B4;//USDT代币
        uthreeAddress = 0x4067CEae26BcB2ee71eACD4e23C8D56e68bE7855;// USDT30%地址
        ufourAddress = 0x4067CEae26BcB2ee71eACD4e23C8D56e68bE7855;//USDT 40%地址
        ulpAddress = 0x4067CEae26BcB2ee71eACD4e23C8D56e68bE7855; //USDT lp接收地址

        arbthreeAddress = 0x4067CEae26BcB2ee71eACD4e23C8D56e68bE7855; //ARB30%地址
        arblpAddress = 0x4067CEae26BcB2ee71eACD4e23C8D56e68bE7855; //ARB lp接收地址

        AR = Token(arbAddress);
        USDT = Token(usdtAddress);
        ARUSDTLP = Token(lpAddress);
        TransferHelper.safeApprove(arbAddress, pancakeRoute2Address, 1 * 10 ** 30);
        TransferHelper.safeApprove(usdtAddress, pancakeRoute2Address, 1 * 10 ** 30);
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
        
        uint256 lpAmount = 0;
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
                address(USDT).safeTransferFrom(msg.sender, address(this),ulprateNumber);
                //30%做lp
                lpAmount =  _swapTokenAndAddLiq(usdtAddress,ulprateNumber);
            }
        }

        if (t == 2) { //AR
            require(AR.balanceOf(msg.sender)>=amount, "Insufficient balance");
            if(arb3rate > 0){
                address(AR).safeTransferFrom(msg.sender, arbthreeAddress, amount.mul(arb3rate).div(100));
            }
            if(arbDestroyRate > 0){
                address(AR).safeTransferFrom(msg.sender, destroyAddress, amount.mul(arbDestroyRate).div(100));
            }
            if(arblprate > 0){
                uint256 arblprateNumber = amount.mul(arblprate).div(100);
                address(AR).safeTransferFrom(msg.sender, address(this), arblprateNumber);
                //30%做LP
                lpAmount = _swapTokenAndAddLiq(arbAddress,arblprateNumber);
            }
        }

        if (t == 3) {
            require(ARUSDTLP.balanceOf(msg.sender) >= amount, "Insufficient balance");
            address(ARUSDTLP).safeTransferFrom(msg.sender, lpAddress, amount);
        }
        
       emit Deposit(t, level, amount, buy_level, beneficiary, noce, lpAmount);
    }

    function _swapTokenAndAddLiq(address _token,uint256 amount) internal returns(uint256) {
        //1.将一半的币卖掉
        uint256 sellAmount = amount.div(2); 
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = _token == arbAddress ? usdtAddress : arbAddress;
        uint[] memory amountOut = IPancakeRouter02(pancakeRoute2Address).getAmountsOut(sellAmount,path);
        uint256 arAmount = _token == arbAddress ? sellAmount : amountOut[1];
        uint256 usdtAmount = _token == arbAddress ? amountOut[1] : sellAmount;
        _swapToken(_token,sellAmount);
        //将LP转到指定地址
        address  lpAcceptAddress = _token == arbAddress ? arblpAddress : ulpAddress;
        //2.添加流动性 
        uint256 lpAmount = _addLiq(arAmount,usdtAmount,lpAcceptAddress);
        return lpAmount;
    }

    // 交换token
    function _swapToken(address _token,uint256 amount) internal {
        address[] memory  path =  new address[](2);
        path[0] = _token;
        path[1] = _token == arbAddress ? usdtAddress : arbAddress;
        IPancakeRouter02(pancakeRoute2Address).swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,address(this),block.timestamp);
    }

    // 添加流动性
    function _addLiq(uint256 arbAmount, uint256 usdtAmount, address lpAcceptAddress) internal returns(uint) {
      (uint amountA,uint amountB,uint256 lpAmount) = IPancakeRouter02(pancakeRoute2Address).addLiquidity(arbAddress,usdtAddress,arbAmount,usdtAmount,0,0,lpAcceptAddress,block.timestamp);
      remainArb.add(amountA);
      remainUsdt.add(amountB);
      return lpAmount;
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

        if (t == 2) { //AR
            require(AR.balanceOf(address(this))>=amount, "Insufficient balance");
            if(feeRate > 0){
                address(AR).safeTransfer(feeAddress, amount.mul(feeRate).div(100));
            }
            address(AR).safeTransfer(beneficiary, amount.mul(uint256(100).sub(feeRate)).div(100));
        }

        if (t == 3) { //ARUSDTLP
            require(ARUSDTLP.balanceOf(address(this))>=amount, "Insufficient balance");
            if(feeRate > 0){
                address(ARUSDTLP).safeTransfer(feeAddress, amount.mul(feeRate).div(100));
            }
            address(ARUSDTLP).safeTransfer(beneficiary, amount.mul(uint256(100).sub(feeRate)).div(100));
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
        uint256 arb3rate_,
        uint256 arbDestroyRate_,
        uint256 arblprate_,
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

        if(arb3rate_ < 100){
            arb3rate = arb3rate_;
        }
        if(arbDestroyRate_ < 100){
            arbDestroyRate = arbDestroyRate_;
        }
        if(arblprate_ < 100){
            arblprate = arblprate_;
        }

        require(arb3rate + arbDestroyRate + arblprate == 100 , "arbrate sum not 100");

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
        address arbthreeAddress_,
        address arblpAddress_,
        address feeAddress_
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
        if(arbthreeAddress_ != address(0)){
            arbthreeAddress = arbthreeAddress_;
        }
        if(arblpAddress_ != address(0)){
            arblpAddress = arblpAddress_;
        }
        if(feeAddress_ != address(0)){
            feeAddress = feeAddress_;
        }
        return true;
    }
}