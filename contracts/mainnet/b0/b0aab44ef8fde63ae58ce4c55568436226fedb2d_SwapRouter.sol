/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// File: node_modules\@openzeppelin\contracts\utils\Context.sol


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

// File: @openzeppelin\contracts\access\Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts\SwapRouter.sol



pragma solidity ^0.8.0;



interface IParaswapRouter {
    struct SimpleData {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address[] callees;
        bytes exchangeData;
        uint256[] startIndexes;
        uint256[] values;
        address payable beneficiary;
        address payable partner;
        uint256 feePercent;
        bytes permit;
        uint256 deadline;
        bytes16 uuid;
    }
    function simpleSwap(
        SimpleData memory data
    ) external payable returns (uint256 receivedAmount);
    function getTokenTransferProxy() external view returns (address);
}

interface IAirSwapLight {
    function swap(
        uint256 nonce,
        uint256 expiry,
        address signerWallet,
        IERC20 signerToken,
        uint256 signerAmount,
        IERC20 senderToken,
        uint256 senderAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function ORDER_TYPEHASH() external view returns(bytes32);
    function DOMAIN_SEPARATOR() external view returns(bytes32);
    function signerFee() external view returns(uint256);
    function authorize(address sender) external;
}

interface IZeroExRouter {
    function sellToPancakeSwap(address[] memory tokens, uint256 sellAmount, uint256 minBuyAmount, uint8 fork) external payable returns (uint256 buyAmount);
}

interface IPmmRouter {

    struct Order {
        address makerAddress;          
        address takerAddress;          
        address feeRecipientAddress;   
        address senderAddress;         
        uint256 makerAssetAmount;      
        uint256 takerAssetAmount;      
        uint256 makerFee;              
        uint256 takerFee;              
        uint256 expirationTimeSeconds; 
        uint256 salt;                  
        bytes makerAssetData;          
        bytes takerAssetData;           
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;
        uint256 takerAssetFilledAmount;
        uint256 makerFeePaid;          
        uint256 takerFeePaid;          
    }

    function fillOrder(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
    external
    returns (FillResults memory fillResults);
}

interface IOneInchRouter {
    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }
    function swap(
        address caller,
        SwapDescription calldata desc,
        bytes calldata data
    )
    external
    payable
    returns (uint256 returnAmount, uint256 gasLeft);
}

contract SwapRouter is Ownable{

    address paraswapRouter;
    address airswapLight;
    address zeroExRouter;
    address pmmRouter;
    address oneInchRouter;
    address feeAddress;

    constructor() {
        paraswapRouter = address(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57);
        airswapLight = address(0xc98314a5077DBa8F12991B29bcE39F834E82e197);
        zeroExRouter = address(0xDef1C0ded9bec7F1a1670819833240f027b25EfF);
        pmmRouter = address(0x3F93C3D9304a70c9104642AB8cD37b1E2a7c203A);
        oneInchRouter = address(0x1111111254fb6c44bAC0beD2854e76F90643097d);
        feeAddress = address(0x0B25a50F0081c177554e919EeFf192Cfe9EfDe15);
    }

    receive() external payable {}

    function swap(string memory aggregatorId, address tokenFrom, uint256 amount, bytes memory data) public payable{

        bytes4 fName;
        uint256 position;
        uint256 receivedAmount;
        uint256 feeAmount;
        address destinationToken;

        assembly {
            fName := mload(add(data, 0x20))
        }

        if(fName == 0x5f575529) {
            position = 0xE4;
            assembly {
                feeAmount := mload(add(data, 0x1A4))
            }
        }
        else{
            assembly {
                feeAmount := mload(add(data, 0xC0))
            }
        }

        assembly {
            destinationToken := mload(add(data, add(position, 0x40)))
        }

        if(tokenFrom != address(0)){
            IERC20(tokenFrom).transferFrom(msg.sender, address(this), amount);
        }

        if(keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("0xFeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), zeroExRouter) == 0){
                    IERC20(tokenFrom).approve(zeroExRouter, type(uint256).max);
                }
            }
            bytes memory exSwapData;
            position = position + 0x120;
            assembly {
                exSwapData := mload(add(data, 0x0))
                let cc := add(data, position)
                exSwapData := add(cc, 0x0)
            }
            bool success;
            bytes memory result;
            if(tokenFrom != address(0)){
                (success, result) = zeroExRouter.call(exSwapData);
            }
            else{
                uint256 inputAmount;
                assembly {
                    inputAmount := mload(add(exSwapData, 0x64))
                }
                (success, result) = zeroExRouter.call{value:inputAmount}(exSwapData);
            }
            if(success){
                assembly {
                    receivedAmount := mload(add(result, 0x20))
                }
            }
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("oneInchV4FeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), oneInchRouter) == 0){
                    IERC20(tokenFrom).approve(oneInchRouter, type(uint256).max);
                }
            }
            bytes memory oneInchData;
            position = position + 0x120;
            assembly {
                oneInchData := mload(add(data, 0x0))
                let cc := add(data, position)
                oneInchData := add(cc, 0x0)
            }
            (address _caller, IOneInchRouter.SwapDescription memory desc, bytes memory _data) = parseOneInchData(oneInchData);
            if(tokenFrom != address(0)){
                (receivedAmount, ) = IOneInchRouter(oneInchRouter).swap(_caller, desc, _data);
            }
            else{
                uint256 inputAmount;
                assembly {
                    inputAmount := mload(add(oneInchData, 0x104))
                }
                (receivedAmount, ) = IOneInchRouter(oneInchRouter).swap{value: inputAmount}(_caller, desc, _data);
            }
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("pmmFeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), pmmRouter) == 0){
                    IERC20(tokenFrom).approve(pmmRouter, type(uint256).max);
                }
            }
            bytes memory pmmData;
            uint256 takerAssetFillAmount;
            uint256 takerAssetFillAmountPosition = position + 0x60;
            position = position + 0x180;
            assembly {
                pmmData := mload(add(data, 0x0))
                let cc := add(data, position)
                pmmData := add(cc, 0x0)
                takerAssetFillAmount := mload(add(data, takerAssetFillAmountPosition)) 
            }        
            (IPmmRouter.Order memory order, bytes memory signature) = parsePmmData(pmmData);
            IPmmRouter.FillResults memory fillResults = IPmmRouter(pmmRouter).fillOrder(order, takerAssetFillAmount, signature);
            receivedAmount = fillResults.makerAssetFilledAmount;
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("airswapLightFeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), airswapLight) == 0){
                    IERC20(tokenFrom).approve(airswapLight, type(uint256).max);
                }
            }
            bytes memory airswapData;
            assembly {
                airswapData := mload(add(data, 0x0))
                let cc := add(data, add(0x0, position))
                airswapData := add(cc, 0x0)
            }
            (IERC20 senderToken, uint256 signerAmount) = airSwapLightSwap(airswapData);
            assembly {
                feeAmount := mload(add(data, add(position, 0x160)))
            }
            destinationToken = address(senderToken);
            receivedAmount = signerAmount;
        }
        else if (keccak256(abi.encodePacked((aggregatorId))) == keccak256(abi.encodePacked(("paraswapV5FeeDynamic")))){
            if(tokenFrom != address(0)){
                if(IERC20(tokenFrom).allowance(address(this), IParaswapRouter(paraswapRouter).getTokenTransferProxy()) == 0){
                    IERC20(tokenFrom).approve(IParaswapRouter(paraswapRouter).getTokenTransferProxy(), type(uint256).max);
                }
            }
            bytes memory paraswapData;
            position = position + 0x120;
            assembly {
                paraswapData := mload(add(data, 0x0))
                let cc := add(data, position)
                paraswapData := add(cc, 0x0)
            }
            IParaswapRouter.SimpleData memory simpleData = parseParaswapData(paraswapData);
            if(tokenFrom != address(0)){
                receivedAmount = IParaswapRouter(paraswapRouter).simpleSwap(simpleData);
            }
            else{
                uint256 inputAmount;
                assembly {
                    inputAmount := mload(add(paraswapData, 0x84))
                }
                receivedAmount = IParaswapRouter(paraswapRouter).simpleSwap{value:inputAmount}(simpleData);
            }
        }

        bool success;
        bytes memory result;
        if(tokenFrom != address(0)){
            IERC20(tokenFrom).transfer(feeAddress, feeAmount);
        }
        else{
            (success,) = payable(feeAddress).call{value: feeAmount}("");            
        }
        if(destinationToken != address(0)){
            IERC20(destinationToken).transfer(msg.sender, receivedAmount);
        }
        else{
            (success,result) = payable(msg.sender).call{value: receivedAmount}("");
        }
    }

    function parseParaswapData(bytes memory data) public pure returns(
        IParaswapRouter.SimpleData memory simpleData
    ){
        (simpleData.fromToken,
        simpleData.toToken,
        simpleData.fromAmount,
        simpleData.toAmount,
        simpleData.expectedAmount,
        simpleData.beneficiary,
        simpleData.partner,
        simpleData.feePercent) = getParaswapData_1(data);

        (simpleData.deadline,
        simpleData.uuid,
        simpleData.callees,
        simpleData.exchangeData,
        simpleData.startIndexes,
        simpleData.values,
        simpleData.permit) = getParaswapData_2(data);
        return simpleData;
    }

    function getParaswapData_1(bytes memory data) public pure returns(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 expectedAmount,
        address payable beneficiary,
        address payable partner,
        uint256 feePercent){
        assembly {
            fromToken := mload(add(data, 0x44))
            toToken := mload(add(data, 0x64))
            fromAmount := mload(add(data, 0x84))
            toAmount := mload(add(data, 0xA4))
            expectedAmount := mload(add(data, 0xC4))
            beneficiary := mload(add(data, 0x164))
            partner := mload(add(data, 0x184))
            feePercent := mload(add(data, 0x1A4))
        }        
    }

    function getParaswapData_2(bytes memory data) public pure returns(
        uint256 deadline,
        bytes16 uuid,
        address[] memory callees,
        bytes memory exchangeData,
        uint256[] memory startIndexes,
        uint256[] memory values,
        bytes memory permit){
        uint32 length;
        
        assembly {
            deadline := mload(add(data, 0x1E4))
            uuid := mload(add(data, 0x204))
            length := mload(add(data, 0x224)) // length of callees
            callees := msize()
            mstore(add(callees, 0x00), length)
            for { let n := 0 } lt(n, length) { n := add(n, 1) } {
                mstore(add(callees, mul(add(n, 1), 0x20)), mload(add(data, add(0x244, mul(n, 0x20)))))
            }
            mstore(0x40, add(callees, mul(add(length, 1), 0x20)))
            let position := add(0x244, mul(0x20, length))
            length := mload(add(data, position)) // length of exchangeData

            exchangeData := mload(add(data, 0x0))
            let cc := add(data, position)
            exchangeData := add(cc, 0x0)

            position := add(add(position, length), 60)
            length := mload(add(data, position)) // length of startIndexes
            position := add(position, 0x20)
            startIndexes := msize()
            mstore(add(startIndexes, 0x00), length)
            for { let n := 0 } lt(n, length) { n := add(n, 1) } {
                mstore(add(startIndexes, mul(add(n, 1), 0x20)), mload(add(data, add(position, mul(n, 0x20)))))
            }
            mstore(0x40, add(startIndexes, mul(add(length, 1), 0x20)))

            position := add(position, mul(length, 0x20))
            length := mload(add(data, position)) // length of values
            position := add(position, 0x20)
            values := msize()
            mstore(add(values, 0x00), length)
            for { let n := 0 } lt(n, length) { n := add(n, 1) } {
                mstore(add(values, mul(add(n, 1), 0x20)), mload(add(data, add(position, mul(n, 0x20)))))
            }
            mstore(0x40, add(values, mul(add(length, 1), 0x20)))
            // permit := mload(add(data, 0x60))
        }
    }

    function parseAirSwapData(bytes memory data) public pure returns(
        uint256 nonce,
        uint256 expiry,
        address signerWallet,
        IERC20 signerToken,
        uint256 signerAmount,
        IERC20 senderToken,
        uint256 senderAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ){
        assembly {
            nonce := mload(add(data, 0x20))
            expiry := mload(add(data, 0x40))
            signerWallet := mload(add(data, 0x60))
            signerToken := mload(add(data, 0x80))
            signerAmount := mload(add(data, 0xA0))
            senderToken := mload(add(data, 0xC0))
            senderAmount := mload(add(data, 0xE0))
            v := mload(add(data, 0x100))
            r := mload(add(data, 0x120))
            s := mload(add(data, 0x140))
        }
    }

    function parsePmmData(bytes memory data) public view returns(
        IPmmRouter.Order memory order,
        bytes memory signature
    ){
        (order.makerAddress,          
        order.takerAddress,          
        order.feeRecipientAddress,   
        order.senderAddress,         
        order.makerAssetAmount,      
        order.takerAssetAmount,      
        order.makerFee) = getPmmOrderInfo_1(data);

        (order.takerFee,              
        order.expirationTimeSeconds, 
        order.salt,                  
        order.makerAssetData,          
        order.takerAssetData,
        signature) = getPmmOrderInfo_2(data);
    }

    function getPmmOrderInfo_1(bytes memory data) public view returns(
        address makerAddress,
        address takerAddress,
        address feeRecipientAddress,
        address senderAddress,
        uint256 makerAssetAmount,
        uint256 takerAssetAmount,
        uint256 makerFee){
        assembly {
            makerAddress := mload(add(data, 0x20))
            // takerAddress := mload(add(data, 0x40))
            feeRecipientAddress := mload(add(data, 0x60))
            senderAddress := mload(add(data, 0x80))
            makerAssetAmount := mload(add(data, 0xA0))
            takerAssetAmount := mload(add(data, 0xC0))
            makerFee := mload(add(data, 0xE0))
        }
        takerAddress = address(this);
    }

    function getPmmOrderInfo_2(bytes memory data) public pure returns(
        uint256 takerFee,
        uint256 expirationTimeSeconds,
        uint256 salt,
        bytes memory makerAssetData,
        bytes memory takerAssetData,
        bytes memory signature){
        uint256 length;
        assembly {
            takerFee := mload(add(data, 0x100))
            expirationTimeSeconds := mload(add(data, 0x120))
            salt := mload(add(data, 0x140))

            let position := 0x1A0
            length := mload(add(data, position)) // length of markerAssetData
            makerAssetData := mload(add(data, 0x0))
            let cc := add(data, 0x1A0)
            makerAssetData := add(cc, 0x0)

            position := add(add(position, length), 60)
            length := mload(add(data, position)) // length of takerAssetData
            takerAssetData := mload(add(data, 0x0))
            cc := add(data, position)
            takerAssetData := add(cc, 0x0)

            position := add(add(position, length), 60)
            signature := mload(add(data, 0x0))
            cc := add(data, position)
            signature := add(cc, 0x0)
        }
    }

    function parseOneInchData(bytes memory data) public pure returns(
        address _caller,
        IOneInchRouter.SwapDescription memory desc,
        bytes memory _data
    ){
        assembly {
            _caller := mload(add(data, 0x24))
        }

        (desc.srcToken,
        desc.dstToken,
        desc.srcReceiver,
        desc.dstReceiver,
        desc.amount,
        desc.minReturnAmount,
        desc.flags) = getOneInchDescData_1(data);

        (desc.permit,
        _data) = getOneInchDescData_2(data);
    }

    function getOneInchDescData_1(bytes memory data) public pure returns(
        IERC20 srcToken,
        IERC20 dstToken,
        address payable srcReceiver,
        address payable dstReceiver,
        uint256 amount,
        uint256 minReturnAmount,
        uint256 flags
    ){
        assembly {
            srcToken := mload(add(data, 0x84))
            dstToken := mload(add(data, 0xA4))
            srcReceiver := mload(add(data, 0xC4))
            dstReceiver := mload(add(data, 0xE4))
            amount := mload(add(data, 0x104))
            minReturnAmount := mload(add(data, 0x124))
            flags := mload(add(data, 0x144))
        }
    }

    function getOneInchDescData_2(bytes memory data) public pure returns(
        bytes memory permit,
        bytes memory _data
    ){
        uint256 lengthOfPermit;
        assembly {
            permit := mload(add(data, 0x0))
            let cc := add(data, 0x184)
            permit := add(cc, 0x0)
            lengthOfPermit := mload(add(data, 0x184))

            let position := add(0x184, lengthOfPermit)
            _data := mload(add(data, 0x0))
            cc := add(data, add(position, 0x20))
            _data := add(cc, 0x0)
        }
    }

    function airSwapLightSwap(bytes memory airswapData) public returns(IERC20, uint256){
        (
            uint256 nonce,
            uint256 expiry,
            address signerWallet,
            IERC20 signerToken,
            uint256 signerAmount,
            IERC20 senderToken,
            uint256 senderAmount,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = parseAirSwapData(airswapData);
        {
            bytes32 hash = keccak256(
                abi.encode(
                IAirSwapLight(airswapLight).ORDER_TYPEHASH(),
                nonce,
                expiry,
                signerWallet,
                signerToken,
                signerAmount,
                IAirSwapLight(airswapLight).signerFee(),
                address(this),
                senderToken,
                senderAmount
                )
            );
            bytes32 digest =
            keccak256(abi.encodePacked("\x19\x01", IAirSwapLight(airswapLight).DOMAIN_SEPARATOR(), hash));
            address signatory = ecrecover(digest, v, r, s);
            IAirSwapLight(airswapLight).authorize(signatory);
        }

        IAirSwapLight(airswapLight).swap(
            nonce,
            expiry,
            signerWallet,
            signerToken,
            signerAmount,
            senderToken,
            senderAmount,
            v,
            r,
            s
        );
        return (senderToken, signerAmount);
    }

    function updateFeeAddress(address _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }
}