pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed

import "./Profile.sol";

pragma abicoder v2;


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



interface router01 {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        uint _lockDuration
    ) external returns (uint amountA, uint amountB, uint liquidity);

      function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        uint _lockDuration
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Launchpad is Profile  {

    address public launchFactory;
    using ECDSA for address;
   

    modifier checkWhiteList() {
            if (launchpadDetails[address(this)]._participationType == 2)
            require(whitelistUser[_msgSender()],'caller must whitelist user');
        _;
    }

    modifier checkStandardTime() {
            if (launchpadDetails[address(this)]._claimType == 2)
            require(block.timestamp >= standardTime,'Time not reached');
        _;
    }

    constructor() {
        launchFactory = msg.sender;
    }

    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    struct LaunchpadDetails {
        uint8 currencyType;
        uint8 _participationType;
        uint8 _claimType;
        uint8 _ownClaimType;
        uint256 presaleRate;
        uint256 hardCap;
        uint256 minimumBuy;
        uint256 maximumBuy;
        uint256 startTime;
        uint256 endTime;
        uint256 _tokenPercent;
        uint256 _bnbPercent;
        address _buyAddr;
    }

    IBEP20 public token;
    address public buyAddr;
    bool public afterClaimFee;
    address public productOwner;
    address public signer;
    uint256 public ownerFee = 5e18;
    uint256 public standardTime;
    uint256 public releseAmount;
    bool public liquidity;
    address public router;
    bool public liquidityCompleted;

    mapping(address => LaunchpadDetails) public launchpadDetails;
    mapping(bytes32 => bool)public msgHash;
    mapping(address => bool)public isClaim;

    receive()external payable{}
     
    function initialize (
        initialSaleType memory saleType,
        presaleInfo memory presale,
        Liquidity memory liq,
        IBEP20 _token,
        address _admin,
        address _productOwn,
        uint256 _ownerFee,
        address _sig
    ) external payable {
        require(_msgSender() == launchFactory,'Not factory');
        launchpadDetails[address(this)] = LaunchpadDetails({
             currencyType : saleType.currencyType,
             _participationType   : saleType._participationType,
             _claimType  : saleType._claimType,
             _ownClaimType  : saleType._ownClaimType,
              _tokenPercent : liq._tokenBPercent,
             _bnbPercent  : liq._tokenAPercent,
             _buyAddr   :    saleType._buyAddr,
             presaleRate  : presale.presaleRate,
             hardCap  : presale.hardCap,
             minimumBuy  : presale.minimumBuy,
             maximumBuy  : presale.maximumBuy,
             startTime   : presale.startTime,
             endTime     : presale.endTime
             
        });

        token = _token;
        buyAddr = saleType._buyAddr;
        transferOwnership(_admin);
        afterClaimFee = saleType.afterClaimFee;
        productOwner = _productOwn;
        ownerFee = _ownerFee;
        signer = _sig;
        standardTime = saleType.standardTime;
        liquidity = liq.liquidity;
        router = liq.router;
    }



    function addWhiteList(address[] memory _user,bool status) external onlyOwner {
        require(launchpadDetails[address(this)]._participationType == 2,'Sale not in whitelist variant');
        for (uint8 i = 0;i < _user.length;i++){
            whitelistUser[_user[i]] = status;
        }
    }

    function buy(uint256 _amount) external payable checkWhiteList() {
      LaunchpadDetails storage launch = launchpadDetails[address(this)];
      uint8 currencyType = internalPurpose(buyAddr);
      require(block.timestamp > launch.startTime && launch.endTime >= block.timestamp,'time issue');
      uint256 amt = (currencyType == 0)? msg.value: _amount;

      if (currencyType == 1) {
          IBEP20(buyAddr).safeTransferFrom(_msgSender(),address(this),amt);
      }
      
      uint8 decimal = (buyAddr == address(0))? 18:IBEP20(buyAddr).decimals();
      uint256 reward = calc(1,launch.presaleRate,amt,launch.maximumBuy,launch.minimumBuy,decimal);
      require(this.hardcapCalc() >= reward,'amount reached hardcap');
      releseAmount += reward;
      _userUpdate(_msgSender(),amt,reward);

      if (launch._claimType == 4) {
       _executeInternal(_msgSender(),reward);
       users[_msgSender()].claimAmount -= reward;
       users[_msgSender()].depAmount = 0;
      }
    }

    function hardcapCalc() external view returns(uint256) {
        return (launchpadDetails[address(this)].hardCap - releseAmount);
    }

    function _userUpdate(address _user,uint256 _amount,uint256 _claimAmt) private {
        userDetails storage user = users[_user];
        user.depAmount += _amount;
        user.claimAmount += _claimAmt;
        user.depositTime = block.timestamp;
    }

    function _executeInternal(address _user,uint256 _amount) private {
         token.safeTransfer(_user,_amount);
    }

    function claim() external checkStandardTime{
        LaunchpadDetails storage launch = launchpadDetails[address(this)];
        
        userDetails storage user = users[_msgSender()];
        require(user.claimAmount > 0 && user.depAmount > 0,'Not yet deposit');

        if (launch._claimType != 2) {
        require(block.timestamp > launch.endTime,'sale not end');
        }

        require(launch._claimType != 3 && launch._claimType != 4 ,'Not for vest and automation');
        uint8 decimal = (buyAddr == address(0))? 18:IBEP20(buyAddr).decimals();
        uint256 reward = calc(1,launch.presaleRate,user.depAmount,launch.maximumBuy,launch.minimumBuy,decimal);
        _executeInternal(_msgSender(),reward);
        user.claimAmount -= reward;
        user.depAmount = 0;
        
    }

    function vestClaim(uint256 _amount,uint256 _time,bytes memory _signature) external {
        LaunchpadDetails storage launch = launchpadDetails[address(this)];
       
        userDetails storage user = users[_msgSender()];
        require(launch._claimType == 3,'only for vesting');
        require(user.depAmount > 0,'user not yet deposit');

         bytes32 messageHash = message(_msgSender(),_amount,_time);
         require(!msgHash[messageHash], "claim: signature duplicate");
        
           //Verifes signature    
        address src = verifySignature(messageHash, _signature);
        require(signer == src, " claim: unauthorized");
        
        if (user.reward + _amount > user.claimAmount) {
            _amount = user.claimAmount - user.reward;
            user.depAmount = 0;
        }
        _executeInternal(_msgSender(),_amount);
        user.reward += _amount;
        msgHash[messageHash] = true;
    }

    function viewAmount(address _user)external view returns(uint256){
        LaunchpadDetails storage launch = launchpadDetails[address(this)];
        require(launch._claimType != 3,'not for vesting');
        uint8 decimal = (buyAddr == address(0))? 18:IBEP20(buyAddr).decimals();
        return calc(1,launch.presaleRate,users[_user].depAmount,launch.maximumBuy,launch.minimumBuy,decimal);
    }

    function adminClaim(address to,uint256 _amount) external onlyOwner {
        LaunchpadDetails storage launch = launchpadDetails[address(this)];
        
        if (liquidity && !liquidityCompleted)
        _amount = _amount - _amount*launch._bnbPercent/100e18;


        if (launch._ownClaimType == 1){
            require(block.timestamp > launch.endTime,'Endtime not yet finish');
            _adminInternal(to,_amount);
        }
        else _adminInternal(to,_amount);
    }

    function _adminInternal(address _user,uint256 _amount) private {
        uint8 currencyType = internalPurpose(buyAddr);
        IBEP20 _token = IBEP20(buyAddr);
        _amount = afterClaimCalc(currencyType,_amount,_token);
        if (currencyType == 0)
        payable(_user).transfer(_amount);
        else _token.safeTransfer(_user,_amount);
    }

    function afterClaimCalc (uint8 _type,uint256 _amount,IBEP20 _token) private returns(uint256) {
        if (!afterClaimFee)
        return _amount;
        else{
            uint256 shareAmt = _amount*ownerFee/100e18;
            if (_type == 0)
            payable(productOwner).transfer(shareAmt);
            else _token.safeTransfer(productOwner,shareAmt);
            return _amount - shareAmt;
        }
    }

    function addLiquidity(uint _tokenAmountA, uint _tokenAmountB, uint deadline, address _lpReceiver, uint _lock) external onlyOwner {
        require(block.timestamp > launchpadDetails[address(this)].endTime,'sale not end');
        if (buyAddr == address(0)) {
        token.safeApprove(router,_tokenAmountB);
        router01(router).addLiquidityETH{value: _tokenAmountA}( 
                address(token),
                _tokenAmountB,
                0,
                0,
                _lpReceiver,
                deadline,
                _lock
            );
        }
        else {
        IBEP20(buyAddr).safeApprove(router,_tokenAmountA);
        IBEP20(token).safeApprove(router,_tokenAmountB);
        router01(router).addLiquidity( 
                buyAddr,
                address(token),
                _tokenAmountA,
                _tokenAmountB,
                0,
                0,
               _lpReceiver,
               deadline,
               _lock
            );
        }
        liquidityCompleted = true;
    }  

    function updateParticipateType(uint8 _type,uint256 _fee) external payable onlyOwner {
         if (_type == 2) {
             require(msg.value == _fee);
             payable(productOwner).transfer(_fee);
         }
         launchpadDetails[address(this)]._participationType = _type;
    }

    function updateStandardTime(uint256 _time) external  onlyOwner {
        standardTime = _time;
    }

    function viewAmountUser(uint8 _type,uint256 _amt) external view returns (uint256){
        LaunchpadDetails storage launch = launchpadDetails[address(this)];

        uint8 decimal = (buyAddr == address(0))? 18:IBEP20(buyAddr).decimals();
        return calc(_type,launch.presaleRate,_amt,launch.maximumBuy,launch.minimumBuy,decimal);
    }

    /**
    * @dev Ethereum Signed Message, created from `hash`
    * @dev Returns the address that signed a hashed message (`hash`) with `signature`.
    */
    function verifySignature(bytes32 _messageHash, bytes memory _signature) public pure returns (address signatureAddress)
    {
        bytes32 hash = ECDSA.toEthSignedMessageHash(_messageHash);
        signatureAddress = ECDSA.recover(hash, _signature);
    }
    
    /**
    * @dev Returns hash for given data
    */
    function message(address  _receiver ,uint256 amount,uint256 time)
        public pure returns(bytes32 messageHash)
    {
        messageHash = keccak256(abi.encodePacked(_receiver,amount,time));
    }
    
    // updaate signer address
    function setSigner(address _signer)public onlyOwner{
        signer = _signer;
    }

    function emergencyWithdraw(address to,uint256 amount) external onlyOwner {
         token.safeTransfer(to,amount);
    }
}

contract LaunchpadFactory is Profile {

    address public routeraddr;
    address[] public addressList;
    using SafeBEP20 for IBEP20;

    uint256 public productOwnerFee = 5e18;
    
    uint32 public launchpadCount;
    address public productOwn;

    mapping(uint8 => uint256) public depositAmount;
    mapping(uint8 => uint256) public participationType;
    mapping(uint8 => uint256) public claimType;
    mapping(uint8 => uint256) public ownClaimType;

    event NewLaunchpadContract(address indexed launchpad);

    constructor (address _router,address _productOwn) {
        routeraddr = _router;
        productOwn = _productOwn;

        depositAmount[1] = 1e18;
        depositAmount[2] = 1e18;
        depositAmount[3] = 1e18;

        participationType[2] = 0.5e18;
        claimType[4] = 1e18;
        ownClaimType[2] = 1e18; 
    }

    receive()external payable {}

    function createSale (
        initialSaleType memory saleType,
        presaleInfo memory presale,
        Liquidity memory liq,
        IBEP20 token,
        address _admin,
        address _signer
        ) public payable {
            require(address(token) != address(0),'invalid token');
            require(token.totalSupply() > 0,'token should be in supply');


            if (saleType._claimType == 2)
            require(saleType.standardTime > 0 && saleType.standardTime > presale.startTime,'Not be zero');


            uint256 finalAmt;
            uint256 supply = presale.hardCap;

            if (!saleType.afterClaimFee) {
            finalAmt += depositAmount[saleType.currencyType];
            
           
            if (participationType[saleType._participationType] > 0){
                finalAmt += participationType[saleType._participationType];
            }

            if (claimType[saleType._claimType] > 0){
                finalAmt += claimType[saleType._claimType];
            }

            if (ownClaimType[saleType._ownClaimType] > 0){
                finalAmt += ownClaimType[saleType._ownClaimType];
            }

            require(msg.value >= finalAmt,'insufficient amount');
           
            }


            if (liq.liquidity)
            supply = supply + supply*liq._tokenBPercent/100e18;



            token.safeTransferFrom(msg.sender,address(this),supply);

            bytes memory bytecode = type(Launchpad).creationCode;
            bytes32 salt = keccak256(abi.encodePacked(token, liq._tokenAPercent, liq._tokenBPercent, block.timestamp));
            address payable launchpadAddress;

            assembly {
            launchpadAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }

            Launchpad(launchpadAddress).initialize(
                 saleType,
                 presale,
                 liq,
                 token,
                 _admin,
                productOwn,
                productOwnerFee,
                _signer
            );

            token.safeTransfer(launchpadAddress,supply);

            addressList.push(launchpadAddress);
            launchpadCount = uint32(addressList.length);
            emit NewLaunchpadContract(launchpadAddress);
    }

    function adminWithdraw(address _to,uint256 _amount,address _source) external onlyOwner {
        if (_source == address(0))
        payable(_to).transfer(_amount);
        else IBEP20(_source).transfer(_to,_amount);
    }

    function updateParticipationType(uint8 _type,uint256 _fee) external onlyOwner {
         participationType[_type] = _fee;
    }

    function updateClaimType(uint8 _type,uint256 _fee) external onlyOwner {
        claimType[_type] = _fee;
    }

    function updateOwnClaimType(uint8 _type,uint256 _fee) external onlyOwner {
        ownClaimType[_type] = _fee;
    }

    function updateDepositAmount(uint8 _type,uint256 _amount) external onlyOwner {
         depositAmount[_type] = _amount;
    }

    function updateProductAddress(address _new) external onlyOwner {
        productOwn = _new;
    }

    function updateProductOwnerFee(uint256 _productOwnerFee) external onlyOwner {
       productOwnerFee = _productOwnerFee;
    }

    function viewAmount(uint8 _type,uint256 _perBNBtoken,uint256 _depositAmt,uint256 _maxAmt,uint256 _min,uint8 _decimal) external pure returns (uint256){
       return calc(_type,_perBNBtoken,_depositAmt,_maxAmt,_min,_decimal);
    }

}

function calc(uint8 _type,uint256 _perBNBtoken,uint256 _depositAmt,uint256 _maxAmt,uint256 _min,uint8 _decimal) pure returns(uint256) {
 
 uint256 decimal = (10 **_decimal);

        if (_type == 1) {
            uint256 amt = _perBNBtoken*_depositAmt/decimal;
            require(_maxAmt >= amt && _min <= amt,'amount exceeds maximum amount');
            return (_perBNBtoken*_depositAmt)/decimal;
        }
        else {
            return (decimal*_depositAmt)/_perBNBtoken;
        }
}

function internalPurpose(address _buy) pure returns(uint8){
        if (_buy == address(0)) return 0;
        else return 1;
}

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed
import "./Ownable.sol";


contract Profile is Ownable {

    struct userDetails {
       uint256 depAmount;
       uint256 claimAmount;
       uint256 depositTime;
       bool initialClaimed;
       uint8 userClaimCount;
       uint256 unStakeTime;
       uint256 lastClaim;
       uint256 reward;
    }

    struct initialSaleType {
        uint8 currencyType;
        uint8 _participationType;
        uint8 _claimType;
        uint8 _ownClaimType;
        address _buyAddr;
        bool afterClaimFee;
        uint256 standardTime;
    }

    struct presaleInfo {
        uint256 presaleRate;
        uint256 hardCap;
        uint256 minimumBuy;
        uint256 maximumBuy;
        uint256 startTime;
        uint256 endTime;
    }

    struct Liquidity {
        address router;
        bool liquidity;
        address tokenA;
        address tokenB;
        uint256 _tokenAPercent;
        uint256 _tokenBPercent;
        address to;
        uint _lock;
    }


    mapping(address =>  userDetails)public users;
    mapping(address => bool) public  whitelistUser;

}

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
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
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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