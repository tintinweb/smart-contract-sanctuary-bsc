// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import "../utils/math/SafeMath.sol";
import "../interfaces/IBridgeSwapOutFacet.sol";
import "../interfaces/IAccessFacet.sol";
import "../interfaces/IBridgeManagerFacet.sol";
import "../interfaces/IFeeManagerFacet.sol";
import "../interfaces/IERC20.sol";

contract BridgeSwapOutFacet is IBridgeSwapOutFacet {

    // Control this facet by fee manager address
    using SafeMath for uint256;

     // Swap event thrown to contract event
    event BridgeOutEvent(
        address _tokenAddr,
        address _from,
        string _to,
        string _memoText,
        uint256 _amount,
        uint256 _feeNormal,
        uint256 _feePercent,
        uint256 _totalRecived,
        string _ticket,
        uint256 _destChain,
        bool isAutoTopup

    );
    event BalanceOutStatementEvent(
        address _tokenAddr,
        uint256 _balanceBridgeIn,
        uint256 _balanceHotWallet,
        uint256 _balanceFeeNormalWallet,
        uint256 _balanceFeePercentWallet,
        bool isAutoTopup
    );
    // swap
    // out of this chain to other chain
    function bridgeOut(
        address _tokenAddr,
        string memory _toAddr,
        string memory _toMemo,
        uint256 _amount,
        string memory _ticket,
        uint256 _destChain
    ) external payable override returns (bool) {
        // check emergency in case critical error
        require(IBridgeManagerFacet(address(this)).getEmergency() == false,"BridgeSwapOutFacet: Bridge is in emergency");
        
         // To check Bridge Ticket ID is require
        require(
            bytes(_ticket).length > 0,
            "Source Transaction ID is required"
        );

        LibDiamond.SwapOutTicketStruct memory swapOutTicket = LibDiamond.getSwapOutTicket(_ticket);
        require(swapOutTicket.isExistTicket == false,"BridgeSwapOutFacet: Ticket is ready exist");

        // To check destination address is require
        require(bytes(_toAddr).length > 0, "Destination address is required");

        // To check destination chain of this transaction is require and possible value only be 1 or 2 (1 = Stellar, 2 = Klaytn)

        require(
            // _destChain == 1 || _destChain == 2,
            IBridgeManagerFacet(address(this)).getAllowDestChain(_tokenAddr,_destChain),
            "Destination Chain is require"
        );
        // TODO : require( fee nomal is set ) for sometime forget to set fee

        // TODO : require( fee nomal is set ) for sometime forget to set fee

         // To check bridge amount must gather than or equal minimum limitation amount of each time
        require(
            _amount >= IBridgeManagerFacet(address(this)).getMinimumAmountLimitPerTrans(_tokenAddr),
            "Amount has exceed minimum limit allow"
        );
         // To check bridge amount must less than or equal maximum limitation amount of each time
        require(
            _amount <= IBridgeManagerFacet(address(this)).getMaximumAmountLimitPerTrans(_tokenAddr),
            "Amount has exceed maximum limit allow"
        );
        
        _bridgeProcess(_tokenAddr,_toAddr,_toMemo,_amount,_ticket,_destChain);
        return (true);
    }
    function _bridgeProcess (
        address _tokenAddr,
        string memory _toAddr,
        string memory _toMemo,
        uint256 _amount,
        string memory _ticket,
        uint256 _destChain
        ) private {
        uint256 feeNormal = IFeeManagerFacet(address(this)).getBridgeFeeNormalByChain(_tokenAddr,_destChain);
        uint256 feePercent = IFeeManagerFacet(address(this)).calCulateFeePercent(_tokenAddr,_amount,_destChain);
        uint256 totalFee = feeNormal.add(feePercent);
        uint256 userTotalRecive = _amount.sub(totalFee);

        // check amount >= total fee
        require(_amount >= totalFee,"Amount must greater than or equal total fee");

        // Store transaction data into mapping with key sourceTx(Bridge Ticket ID)
        { // fix stack too deep
        LibDiamond.SwapOutTicketStruct memory swapOutTicketNew = LibDiamond.SwapOutTicketStruct({
            sourceAddr: msg.sender,
            destAddr: _toAddr,
            destMemoText:_toMemo,
            swapAmount: _amount,
            feeNormalAmount: feeNormal,
            feePercentAmount: feePercent,
            totalRecivedAmount: userTotalRecive,
            destChain:_destChain,
            ticket : _ticket,
            isExistTicket: true
          });
          LibDiamond.setSwapOutTicket(_ticket,swapOutTicketNew);
        }

        _feeTransfer(_tokenAddr,feeNormal,feePercent);

        // Transfer ERC20 Token from sender's wallet to our hot wallet address
        bool isAutoTopup = IBridgeManagerFacet(address(this)).getAutoBridgeTopup(_tokenAddr);

        // check mode auto topup to bridge in
        if(!isAutoTopup){
            // hot wallet tranfer 
            IERC20(_tokenAddr).transferFrom(
                msg.sender, 
                IBridgeManagerFacet(address(this)).getHotWalletAddr(_tokenAddr),
                userTotalRecive
            );
        }else{
            IERC20(_tokenAddr).transferFrom(
                msg.sender, 
                address(this),
                userTotalRecive
            );
        }
            
        // Emit Swap event
        
        emit BridgeOutEvent(
            _tokenAddr,
            msg.sender,
            _toAddr,
            _toMemo,
            _amount,
            feeNormal,
            feePercent,
            userTotalRecive,
            _ticket,
            _destChain,
            isAutoTopup
        );
        
        _balanceEmit(_tokenAddr,isAutoTopup);
        
    }
    function _feeTransfer(address _tokenAddr,uint256 _feeNormal,uint256 _feePercent) private{
        if (_feeNormal != 0) {
            // Transfer swap fee normal to fee normal wallet address
            IERC20(_tokenAddr).transferFrom(
                msg.sender, 
                IFeeManagerFacet(address(this)).getFeeNormalReceiverAddr(_tokenAddr), 
                _feeNormal
            );
        }
        if (_feePercent != 0) {
            // Transfer swap fee percent to fee percent wallet address
            IERC20(_tokenAddr).transferFrom(
                msg.sender,
                IFeeManagerFacet(address(this)).getFeePercentReceiverAddr(_tokenAddr),
                _feePercent
            );
        }
    }
    function _balanceEmit (address _tokenAddr,bool isAutoTopup) private {
        emit BalanceOutStatementEvent(
            _tokenAddr,
            IERC20(_tokenAddr).balanceOf(address(this)),
            IBridgeManagerFacet(address(this)).getHotWalletBalance(_tokenAddr),
            IERC20(_tokenAddr).balanceOf(
                IFeeManagerFacet(address(this)).getFeeNormalReceiverAddr(_tokenAddr)
            ),
            IERC20(_tokenAddr).balanceOf(
                IFeeManagerFacet(address(this)).getFeePercentReceiverAddr(_tokenAddr)
            ),
            isAutoTopup
        );
    }
    function getBridgeOutTicket(string memory _ticket) public view override returns (LibDiamond.SwapOutTicketStruct memory) {
        return LibDiamond.getSwapOutTicket(_ticket);
    }

    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import "../utils/math/SafeMath.sol";

library LibDiamond {

    // enum ItemStatus {Active,InActive,Pause,Other}
    // enum OrderStatus {OnProgress,Success,Other}

    using SafeMath for uint256;
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndSelectorPosition {
        address facetAddress;
        uint16 selectorPosition;
    }

    // struct MockStruct {
    //     string name;
    //     uint256 price;
    // }
    struct SwapInTicketStruct {
        address destAddr;
        string destMemoText;
        uint256 swapAmount;
        string ticket;
        uint256 sourceChain;
        bool isExistTicket;
    }

    struct SwapOutTicketStruct {
        address sourceAddr;
        string destAddr;
        string destMemoText;
        uint256 swapAmount;
        uint256 feeNormalAmount;
        uint256 feePercentAmount;
        uint256 totalRecivedAmount;
        uint256 destChain;
        string ticket;
        bool isExistTicket;
    }
    
    struct FeeStruct {
        address sourceAddr;
        string destAddr;
        string destMemoText;
        uint256 swapAmount;
        uint256 feeAmount;
        uint256 destChain;
    }
    

    struct DiamondStorage {
        // function selector => facet address and selector position in selectors array
        mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
        bytes4[] selectors;
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;

        // Eternal Storage for General purpose
        mapping(bytes32 => uint) uIntStorage;
        mapping(bytes32 => address) addressStorage;
        mapping(bytes32 => string) stringStorage;
        mapping(bytes32 => bool) boolStorage;
        mapping(bytes32 => uint256[]) arrayUintStorage;
        
        // MockStruct[] mock;
        mapping(string => SwapInTicketStruct) SwapInTickets;
        mapping(string => SwapOutTicketStruct) SwapOutTickets;
        // ERC20SwapInStruct[] ERC20SwapIns;
        // ERC20SwapOutStruct[] ERC20SwapOuts;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        uint16 selectorCount = uint16(ds.selectors.length);
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        enforceHasContractCode(_facetAddress, "LibDiamondCut: Add facet has no code");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");
            ds.facetAddressAndSelectorPosition[selector] = FacetAddressAndSelectorPosition(_facetAddress, selectorCount);
            ds.selectors.push(selector);
            selectorCount++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Replace facet can't be address(0)");
        enforceHasContractCode(_facetAddress, "LibDiamondCut: Replace facet has no code");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            // can't replace immutable functions -- functions defined directly in the diamond
            require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
            require(oldFacetAddress != _facetAddress, "LibDiamondCut: Can't replace function with same function");
            require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");
            // replace old facet address
            ds.facetAddressAndSelectorPosition[selector].facetAddress = _facetAddress;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        uint256 selectorCount = ds.selectors.length;
        require(_facetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            FacetAddressAndSelectorPosition memory oldFacetAddressAndSelectorPosition = ds.facetAddressAndSelectorPosition[selector];
            require(oldFacetAddressAndSelectorPosition.facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
            // can't remove immutable functions -- functions defined directly in the diamond
            require(oldFacetAddressAndSelectorPosition.facetAddress != address(this), "LibDiamondCut: Can't remove immutable function.");
            // replace selector with last selector
            selectorCount--;
            if (oldFacetAddressAndSelectorPosition.selectorPosition != selectorCount) {
                bytes4 lastSelector = ds.selectors[selectorCount];
                ds.selectors[oldFacetAddressAndSelectorPosition.selectorPosition] = lastSelector;
                ds.facetAddressAndSelectorPosition[lastSelector].selectorPosition = oldFacetAddressAndSelectorPosition.selectorPosition;
            }
            // delete last selector
            ds.selectors.pop();
            delete ds.facetAddressAndSelectorPosition[selector];
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }

    // Support Interfaces
    function supportsInterface(bytes4 interfaceId) internal view returns (bool) {
        DiamondStorage storage ds = diamondStorage();
        return ds.supportedInterfaces[interfaceId];
    }
    function registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "Bridge: invalid interface id");
        DiamondStorage storage ds = diamondStorage();
        ds.supportedInterfaces[interfaceId] = true;
    }


    // Eternal internal functions
    // *** Getter Methods ***
    function getSwapOutTicket(string memory _ticket) internal view returns (SwapOutTicketStruct memory) {
        DiamondStorage storage ds = diamondStorage();
        return ds.SwapOutTickets[_ticket];
    }
     function getSwapInTicket(string memory _ticket) internal view returns (SwapInTicketStruct memory) {
        DiamondStorage storage ds = diamondStorage();
        return ds.SwapInTickets[_ticket];
    }

    function getUint(bytes32 _key) internal view returns(uint) {
        DiamondStorage storage ds = diamondStorage();
        return ds.uIntStorage[_key];
    }

    function getAddress(bytes32 _key) internal view returns(address) {
        DiamondStorage storage ds = diamondStorage();
        return ds.addressStorage[_key];
    }

    function getString(bytes32 _key) internal view returns(string memory) {
        DiamondStorage storage ds = diamondStorage();
        return ds.stringStorage[_key];
    }

    function getBool(bytes32 _key) internal view returns(bool) {
        DiamondStorage storage ds = diamondStorage();
        return ds.boolStorage[_key];
    }
    function getArrayUint(bytes32 _key) internal view returns(uint256[] storage) {
        DiamondStorage storage ds = diamondStorage();
        return ds.arrayUintStorage[_key];
    }

    // *** Setter Methods ***
    function setSwapOutTicket(string memory _ticket, SwapOutTicketStruct memory _ticketStruct) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.SwapOutTickets[_ticket] = _ticketStruct;
    }
    function setSwapInTicket(string memory _ticket, SwapInTicketStruct memory _ticketStruct) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.SwapInTickets[_ticket] = _ticketStruct;
    }

    function setUint(bytes32 _key, uint _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.uIntStorage[_key] = _value;
    }

    function setAddress(bytes32 _key, address _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.addressStorage[_key] = _value;
    }

    function setString(bytes32 _key, string memory _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.stringStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.boolStorage[_key] = _value;
    }
    function setArrayUint(bytes32 _key, uint256[] memory _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.arrayUintStorage[_key] = _value;
    }
    function initialToken() internal {
        emit Transfer(address(0), diamondStorage().contractOwner, 0);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
}

pragma solidity ^0.8.0;


interface IFeeManagerFacet {
    // Control this facet by fee manager address

    function setFeeNormalReceiverAddr(address _tokenAddr,address _feeAddr) external;
    
    function setFeePercentReceiverAddr(address _tokenAddr,address _feeAddr) external;
    
    function getFeeNormalReceiverAddr(address _tokenAddr) external returns (address);
    
    function getFeePercentReceiverAddr(address _tokenAddr) external returns (address);

    function calCulateFeePercent(address _tokenAddr,uint256 _amount,uint256 _destChainId) view external returns (uint256); 
    
    // use external storage mapper byte 
    // key = keccak256(abi.encodePacked("FEE_AMOUNT",_tokenAddr,_chainId))
    // value: uint = _fee 
    // and
    // key = keccak256(abi.encodePacked("IS_FEE_SET",_tokenAddr,_chainId))
    // value: bool = true when set fee for token
    function setBridgeFeeNormalByChain(address _tokenAddr,uint256 _chainId,uint256 _fee) external;
    
    function getBridgeFeeNormalByChain(address _tokenAddr,uint256 _chainId) external returns(uint256);
    
    function setBridgeFeePercentByChain(address _tokenAddr,uint256 _chainId,uint256 _feePercent) external;

    function getBridgeFeePercentByChain(address _tokenAddr,uint256 _chainId) external returns(uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

pragma solidity ^0.8.0;

import { LibDiamond } from "../libraries/LibDiamond.sol";

interface IBridgeSwapOutFacet {

    function bridgeOut(
        address _tokenAddr,
        string memory _toAddr,
        string memory _toMemo,
        uint256 _amount,
        string memory _ticket,
        uint256 _destChain
    ) external payable returns (bool) ;

    function getBridgeOutTicket(string memory _ticketId)external view returns (LibDiamond.SwapOutTicketStruct memory);
}

pragma solidity ^0.8.0;


interface IBridgeManagerFacet {

   function setEmergency (bool _flag) external;

   function getEmergency () external view returns(bool);
   
   function checkPermisionBridgeControlByToken(address _callerAddr ,address _tokenAddress) external view ;
   
   // dynamic role for bridge token owner
   function setBridgeTokenManger(address _tokenAddress,address _newTokenManager) external;

   function getBridgeTokenManager(address _tokenAddress) external returns(address);

   // true allow mode control by token owner
   function setAllowAccessForTokenOwner(address _tokenAddress, bool _flag) external;

   function getAllowAccessForTokenOwner(address _tokenAddress) external returns(bool);

   function setHotWalletAddr(address _tokenAddr,address _hotWallet) external;

   function getHotWalletAddr(address _tokenAddr) external returns(address);

   function setMaximumAmountLimitPerTrans(address _tokenAddr,uint256 _amountLimitPerTrans) external;

   function getMaximumAmountLimitPerTrans(address _tokenAddr) external returns (uint256);

   function setMinimumAmountLimitPerTrans(address _tokenAddr,uint256 _amountLimitPerTrans) external;

   function getMinimumAmountLimitPerTrans(address _tokenAddr) external returns (uint256);

   function getHotWalletBalance(address _tokenAddr) external view returns (uint256);

   function setAllowDestChain (address _tokenAddr,uint256 _chainId,bool _state) external;

   function getAllowDestChain (address _tokenAddr,uint256 _chainId) external returns (bool);
    
   function erc20ContractBalance(address _tokenAddress) external view returns (uint256);

   function setAllowSourceChain (address _tokenAddr,uint256 _chainId,bool _state) external;

   function getAllowSourceChain (address _tokenAddr,uint256 _chainId) external returns (bool);

   function setAutoBridgeTopup(address _tokenAddr,bool _flag) external;

   function getAutoBridgeTopup(address _tokenAddr) external returns (bool);
}

pragma solidity ^0.8.0;


interface IAccessFacet {
    
    function setContractOwner(address _newOwner) external;
    function getContractOwner() external returns(address);

    function setAddressForRole(string calldata _role,address _address) external;
    function getAddressForRole(string calldata _role) external view returns(address address_) ;
}