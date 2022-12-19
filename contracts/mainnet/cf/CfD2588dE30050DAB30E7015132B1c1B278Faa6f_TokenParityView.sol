// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/ParityLogic.sol";
import "./TokenParityStorage.sol";

/** 
* @author Formation.Fi.
* @notice Implementation of the contract TokenParityView.
*/

contract TokenParityView is  Ownable { 
    TokenParityStorage public tokenParityStorage;
    function setTokenParityStorage(address _tokenParityStorage) public onlyOwner {
        require(_tokenParityStorage != address(0),
            "Formation.Fi: zero address");
        tokenParityStorage = TokenParityStorage(_tokenParityStorage);
    }


    function getTotalTokenValue(uint256 _tokenId, uint256[3] memory _price) public view
        returns(uint256 _totalValue){
        ParityData.Amount memory _tokenBalancePerToken;
        ParityData.Amount memory _depositBalancePerToken;
        ParityData.Amount memory _depositRebalancingBalancePerToken;
        ParityData.Amount memory _withdrawalBalancePerToken;
        (_tokenBalancePerToken.alpha, _tokenBalancePerToken.beta, _tokenBalancePerToken.gamma)  = tokenParityStorage.tokenBalancePerToken(_tokenId);
        (_depositBalancePerToken.alpha, _depositBalancePerToken.beta, _depositBalancePerToken.gamma)= tokenParityStorage.depositBalancePerToken(_tokenId);
        (_depositRebalancingBalancePerToken.alpha, _depositRebalancingBalancePerToken.beta, _depositRebalancingBalancePerToken.gamma) = tokenParityStorage.depositRebalancingBalancePerToken(_tokenId);
        (_withdrawalBalancePerToken.alpha, _withdrawalBalancePerToken.beta, _withdrawalBalancePerToken.gamma) = tokenParityStorage.withdrawalBalancePerToken(_tokenId);
        _totalValue = ParityLogic.getTotalTokenValue( _tokenBalancePerToken,  _depositBalancePerToken,
        _depositRebalancingBalancePerToken, _withdrawalBalancePerToken, _price); 
    } 


    function getTotalNetTokenValue(uint256 _tokenId, uint256[3] memory _price) public view
        returns(uint256 _totalValue){
        ParityData.Amount memory _tokenBalancePerToken;
        ParityData.Amount memory _depositBalancePerToken;
        ParityData.Amount memory _depositRebalancingBalancePerToken;
        (_tokenBalancePerToken.alpha, _tokenBalancePerToken.beta, _tokenBalancePerToken.gamma)  = tokenParityStorage.tokenBalancePerToken(_tokenId);
        (_depositBalancePerToken.alpha, _depositBalancePerToken.beta, _depositBalancePerToken.gamma)= tokenParityStorage.depositBalancePerToken(_tokenId);
        (_depositRebalancingBalancePerToken.alpha, _depositRebalancingBalancePerToken.beta, _depositRebalancingBalancePerToken.gamma) = tokenParityStorage.depositRebalancingBalancePerToken(_tokenId);
        _totalValue = ParityLogic.getNetTotalTokenValue(_tokenBalancePerToken, _depositBalancePerToken,
        _depositRebalancingBalancePerToken, _price);  
    } 


    function getAvailableTokenValue(uint256 _tokenId, uint256 _indexEvent, uint256[3] memory _price) 
        public view returns(uint256 _totalValue) { 
        ParityData.Event[] memory _depositBalancePerTokenPerEvent = tokenParityStorage.getDepositBalancePerTokenPerEvent(_tokenId);
        ParityData.Event[] memory _depositRebalancingBalancePerTokenPerEvent = tokenParityStorage.getDepositRebalancingBalancePerTokenPerEvent(_tokenId);
        ParityData.Amount memory _tokenBalancePerToken;
        (_tokenBalancePerToken.alpha, _tokenBalancePerToken.beta, _tokenBalancePerToken.gamma) = tokenParityStorage.tokenBalancePerToken(_tokenId);
        _totalValue =  ParityLogic.getAvailableTokenValue(_depositBalancePerTokenPerEvent, 
        _depositRebalancingBalancePerTokenPerEvent, _tokenBalancePerToken, _indexEvent, _price) ;
    }


    function getTokenValueToRebalance( uint256 _tokenId, uint256 _indexEvent,
        uint256[3] memory _price) public view returns(uint256, uint256, uint256, uint256){
        ParityData.Event[] memory _depositBalancePerTokenPerEvent = tokenParityStorage.getDepositBalancePerTokenPerEvent(_tokenId);
        ParityData.Event[] memory _depositRebalancingBalancePerTokenPerEvent = tokenParityStorage.getDepositRebalancingBalancePerTokenPerEvent(_tokenId);
        ParityData.Amount memory _tokenBalancePerToken;
        ParityData.Amount memory _amount;
        uint256 _totalValue;
        (_tokenBalancePerToken.alpha, _tokenBalancePerToken.beta, _tokenBalancePerToken.gamma) = tokenParityStorage.tokenBalancePerToken(_tokenId);
        (_amount.alpha, _amount.beta, _amount.gamma, _totalValue) = ParityLogic.getTokenValueToRebalance(_depositBalancePerTokenPerEvent, 
        _depositRebalancingBalancePerTokenPerEvent,
        _tokenBalancePerToken,
        _indexEvent,
        _price);
        return (_amount.alpha, _amount.beta, _amount.gamma, _totalValue);
    }


    function getRebalancingFee(uint256 _tokenId,uint256 _indexEvent,
        uint256[3] memory _price ) public view returns(uint256 _fee){
        ( , , , uint256 _totalValue) =  getTokenValueToRebalance(_tokenId,  _indexEvent,  _price);
        _fee = tokenParityStorage.managementParityParams().getRebalancingFee(_totalValue);
    }


    function getWithdrawalFee(uint256 _tokenId, uint256 _rate, uint256 _indexEvent,
        uint256[3] memory _price ) public view returns(uint256 _totalFee){
        ParityData.Amount memory _depositRebalancingAmount;
        (_depositRebalancingAmount.alpha, _depositRebalancingAmount.beta, _depositRebalancingAmount.gamma) = tokenParityStorage.depositRebalancingBalancePerToken(_tokenId);
        ParityData.Amount memory _withdrawalRebalancingAmount;
        (_withdrawalRebalancingAmount.alpha, _withdrawalRebalancingAmount.beta, _withdrawalRebalancingAmount.gamma) = tokenParityStorage.withdrawalRebalancingBalancePerToken(_tokenId);
        ParityData.Amount memory _tokenBalancePerToken;
        (_tokenBalancePerToken.alpha, _tokenBalancePerToken.beta, _tokenBalancePerToken.gamma) = tokenParityStorage.tokenBalancePerToken(_tokenId);
        uint256 _totalValue = getAvailableTokenValue(_tokenId, _indexEvent,  _price);
        (ParityData.Amount memory _amountToWithdrawFromDeposit, ParityData.Amount memory  _amountToWithdrawFromTokens) = _calculateWithdrawalData( _tokenId, _indexEvent, _rate, _totalValue, _tokenBalancePerToken, 
        _depositRebalancingAmount, _withdrawalRebalancingAmount, _price);
        _totalFee = _calculateWithdrawalFee(  _tokenId, _amountToWithdrawFromDeposit,  _amountToWithdrawFromTokens,  _price);    
    }


    function _calculateWithdrawalData(uint256 _tokenId, uint256 _indexEvent, uint256 _rate,
        uint256 _totalValue, ParityData.Amount memory _tokenBalancePerToken, 
        ParityData.Amount memory _depositRebalancingAmount, ParityData.Amount memory _withdrawalRebalancingAmount,
        uint256[3] memory _price) 
        internal view returns(ParityData.Amount memory _amountToWithdrawFromDeposit, ParityData.Amount memory  _amountToWithdrawFromTokens){
        uint256 _depositValueTotal;
        ParityData.Amount memory _depositValue;
        (_depositValueTotal, _depositValue) = _calculateDepositValue( _indexEvent, _tokenId, _depositRebalancingAmount, _withdrawalRebalancingAmount, _price);
        ( _amountToWithdrawFromDeposit,   _amountToWithdrawFromTokens) = 
        ParityLogic.calculateWithdrawalData( _rate, _totalValue, _depositValueTotal, 
        _depositValue, _tokenBalancePerToken, _price);
    }


    function _calculateWithdrawalFee(uint256 _tokenId,ParityData.Amount memory _amountToWithdrawFromDeposit, ParityData.Amount memory _amountToWithdrawFromTokens,
        uint256[3] memory _price) 
        internal view returns(uint256 _totalFee){
        uint256 _stableAmountToSend = _amountToWithdrawFromDeposit.alpha + _amountToWithdrawFromDeposit.beta +
        _amountToWithdrawFromDeposit.gamma;
        uint256 _stableFee = Math.mulDiv( _stableAmountToSend , tokenParityStorage.managementParityParams().fixedWithdrawalFee(), ParityData.COEFF_SCALE_DECIMALS);
        ParityData.Amount memory _fee; 
        ParityData.Amount memory _flowTimePerToken;
        (_flowTimePerToken.alpha, _flowTimePerToken.beta, _flowTimePerToken.gamma)  = tokenParityStorage.flowTimePerToken(_tokenId);
        ParityData.Fee[] memory _withdrawalVariableFeeData = tokenParityStorage.managementParityParams().getWithdrawalVariableFeeData();
        _fee.alpha = ParityLogic.calculateWithdrawalFees(_flowTimePerToken.alpha, _withdrawalVariableFeeData);
        _fee.beta = ParityLogic.calculateWithdrawalFees(_flowTimePerToken.beta, _withdrawalVariableFeeData);
        _fee.gamma = ParityLogic.calculateWithdrawalFees(_flowTimePerToken.gamma, _withdrawalVariableFeeData);
        _fee = ParityLogic.getWithdrawalTokenFees( _fee, _amountToWithdrawFromTokens, _price);
        _fee = ParityMath.mulMultiCoefDiv2(_fee, _price, ParityData.FACTOR_PRICE_DECIMALS);
        _totalFee =   _stableFee + _fee.alpha + _fee.beta + _fee.gamma;
    }


    function _calculateDepositValue( uint256 _indexEvent, uint256 _tokenId, ParityData.Amount memory _depositRebalancingAmount,
        ParityData.Amount memory _withdrawalRebalancingAmount, uint256[3] memory _price) 
        internal view returns(uint256 _depositValueTotal, ParityData.Amount memory _depositValue){
        ParityData.Event[] memory _depositBalancePerTokenPerEvent = tokenParityStorage.getDepositBalancePerTokenPerEvent(_tokenId);
        uint256 _indexDeposit = ParityLogic.searchIndexEvent(_depositBalancePerTokenPerEvent, _indexEvent);
        if (_indexDeposit < ParityLogic.MAX_INDEX_EVENT){
           _depositValueTotal = _depositBalancePerTokenPerEvent[_indexDeposit].amount.alpha +
           _depositBalancePerTokenPerEvent[_indexDeposit].amount.beta +
           _depositBalancePerTokenPerEvent[_indexDeposit].amount.gamma;
           _depositValue = _depositBalancePerTokenPerEvent[_indexDeposit].amount;
        }
        uint256 _totalDepositRebalancingAmount = _depositRebalancingAmount.alpha + _depositRebalancingAmount.beta +
        _depositRebalancingAmount.gamma;
        uint256 _totalWithdrawalRebalancingAmount = ( _withdrawalRebalancingAmount.alpha * _price[0] + 
        _withdrawalRebalancingAmount.beta * _price[1] + _withdrawalRebalancingAmount.gamma * _price[2])/ ParityData.FACTOR_PRICE_DECIMALS;
        if (_totalDepositRebalancingAmount > _totalWithdrawalRebalancingAmount){
            uint256 _deltaAmount =  _totalDepositRebalancingAmount - _totalWithdrawalRebalancingAmount;
            _depositValueTotal += _deltaAmount;
            _depositValue.alpha += _deltaAmount;
        }
    }


    function isCancelWithdrawalRequest(uint256 _tokenId, uint256 _indexEvent) public view
        returns (bool _isCancel, uint256 _index){
        ParityData.Event[] memory _withdrawalBalancePerTokenPerEvent = tokenParityStorage.getWithdrawalBalancePerTokenPerEvent(_tokenId);
        (_isCancel, _index) = ParityLogic.isCancelWithdrawalRequest(_withdrawalBalancePerTokenPerEvent, _indexEvent);
    }


    function getTotalDepositUntilLastEvent(uint256 _tokenId, uint256 _indexEvent, uint256 _id) public view returns 
        (uint256 _totalValue){
        ParityData.Event[] memory _depositBalancePerTokenPerEvent = tokenParityStorage.getDepositBalancePerTokenPerEvent(_tokenId);
        _totalValue = ParityLogic.getTotalValueUntilLastEventPerProduct(_depositBalancePerTokenPerEvent, 
        _indexEvent, _id);     
    }


    function getTotalWithdrawalUntilLastEvent(uint256 _tokenId, uint256 _indexEvent, uint256 _id) public view returns 
        (uint256 _totalValue){
        ParityData.Event[] memory _withdrawalBalancePerTokenPerEvent = tokenParityStorage.getWithdrawalBalancePerTokenPerEvent(_tokenId);
        _totalValue = ParityLogic.getTotalValueUntilLastEventPerProduct(_withdrawalBalancePerTokenPerEvent, 
        _indexEvent, _id);     
    }


    function getTotalDepositRebalancingUntilLastEvent(uint256 _tokenId, uint256 _indexEvent) public view returns 
        (ParityData.Amount memory _totalValue){
        ParityData.Event[] memory _depositRebalancingBalancePerTokenPerEvent = tokenParityStorage.getDepositRebalancingBalancePerTokenPerEvent(_tokenId);
        _totalValue = ParityLogic.getTotalValueUntilLastEvent(_depositRebalancingBalancePerTokenPerEvent, 
        _indexEvent);     
    }


    function getTotalWithdrawalRebalancingUntilLastEvent(uint256 _tokenId, uint256 _indexEvent,  uint256 _id) public view returns 
        (uint256 _totalValue){
         ParityData.Event[] memory _withdrawalRebalancingBalancePerTokenPerEvent = tokenParityStorage.getWithdrawalRebalancingBalancePerTokenPerEvent(_tokenId);
        _totalValue = ParityLogic.getTotalValueUntilLastEventPerProduct(_withdrawalRebalancingBalancePerTokenPerEvent, 
        _indexEvent, _id);     
    }


    function verifyBurnCondition(uint256 _tokenId) public view returns (bool _result) {
        ParityData.Amount memory _depositBalancePerToken;
        (_depositBalancePerToken.alpha, _depositBalancePerToken.beta, _depositBalancePerToken.gamma) = tokenParityStorage.depositBalancePerToken(_tokenId);
        ParityData.Amount memory _withdrawalBalancePerToken;
        (_withdrawalBalancePerToken.alpha, _withdrawalBalancePerToken.beta, _withdrawalBalancePerToken.gamma) = tokenParityStorage.withdrawalBalancePerToken(_tokenId);
        ParityData.Amount memory _tokenBalancePerToken;
        (_tokenBalancePerToken.alpha, _tokenBalancePerToken.beta, _tokenBalancePerToken.gamma) = tokenParityStorage.tokenBalancePerToken(_tokenId);
        ParityData.Amount memory _depositRebalancingBalancePerToken;
        (_depositRebalancingBalancePerToken.alpha, _depositRebalancingBalancePerToken.beta, _depositRebalancingBalancePerToken.gamma) = tokenParityStorage.depositRebalancingBalancePerToken(_tokenId);
        _result = ParityLogic.verifyBurnCondition( _depositBalancePerToken, _withdrawalBalancePerToken, _tokenBalancePerToken, 
        _depositRebalancingBalancePerToken);
    }
    

    function getwithdrawalFeeRate(uint256 _tokenId) public view returns (ParityData.Amount memory _fee) {
        ParityData.Fee[] memory _withdrawalVariableFeeData = tokenParityStorage.managementParityParams().getWithdrawalVariableFeeData();
        ParityData.Amount memory _flowTimePerToken;
        (_flowTimePerToken.alpha, _flowTimePerToken.beta, _flowTimePerToken.gamma)  = tokenParityStorage.flowTimePerToken(_tokenId);
        _fee.alpha = ParityLogic.calculateWithdrawalFees(_flowTimePerToken.alpha, _withdrawalVariableFeeData);
        _fee.beta = ParityLogic.calculateWithdrawalFees(_flowTimePerToken.beta, _withdrawalVariableFeeData);
        _fee.gamma = ParityLogic.calculateWithdrawalFees(_flowTimePerToken.gamma, _withdrawalVariableFeeData);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./ParityMath.sol";
library ParityLogic {
    uint256 public constant MAX_INDEX_EVENT = 1e18;

    function searchIndexEvent(ParityData.Event[] memory _data, uint256 _indexEvent) 
        internal pure returns (uint256 _index) {
        _index = MAX_INDEX_EVENT;
        if ( _data.length > 0){
            for (uint256 i = 0; i< _data.length; i++){
                if (_data[i].index == _indexEvent){
                    return i;
                }
            }   
        }          
    }
    
    function getTotalValueUntilLastEventPerProduct(ParityData.Event[] memory
        _data, uint256 _indexEvent, uint256 _id) internal pure returns 
        ( uint256 _totalValue) {
        ParityData.Amount memory _amount;
        if (_data.length > 0){
            for (uint256 i = 0; i < _data.length ; ++i){
                if (_data[i].index < _indexEvent){
                    _amount = ParityMath.add2(_amount, _data[i].amount);
                }
            }
        }
        if (_id == 0){
            return _amount.alpha;
        }
        else if (_id == 1){
            return _amount.beta;
        }
        else {
            return _amount.gamma;
        }
    }

    function getTotalValueUntilLastEvent(ParityData.Event[] memory
        _data, uint256 _indexEvent) internal pure returns 
        ( ParityData.Amount memory _totalValue){ 
        if (_data.length > 0){
            for (uint256 i = 0; i < _data.length ; ++i){
                if (_data[i].index < _indexEvent){
                    _totalValue = ParityMath.add2(_totalValue, _data[i].amount);
                }
            }
        }
    }

    function getTotalTokenValue(ParityData.Amount memory _tokenBalancePerToken, ParityData.Amount memory _depositBalancePerToken,
        ParityData.Amount memory _depositRebalancingBalancePerToken, 
        ParityData.Amount memory _withdrawalBalancePerToken, 
        uint256[3] memory _price) 
        internal pure returns ( uint256 _totalValue){
        _totalValue = getNetTotalTokenValue( _tokenBalancePerToken,  _depositBalancePerToken,
         _depositRebalancingBalancePerToken,  _price);
        _totalValue += (_withdrawalBalancePerToken.alpha * _price[0] +  
        _withdrawalBalancePerToken.beta * _price[1] +  
        _withdrawalBalancePerToken.gamma * _price[2])/ParityData.FACTOR_PRICE_DECIMALS;
    }

    function getNetTotalTokenValue(ParityData.Amount memory _tokenBalancePerToken, ParityData.Amount memory _depositBalancePerToken,
        ParityData.Amount memory _depositRebalancingBalancePerToken,  
        uint256[3] memory _price) 
        internal pure returns (uint256){
        ParityData.Amount  memory _value; 
        _value.alpha = (_tokenBalancePerToken.alpha * _price[0]) / ParityData.FACTOR_PRICE_DECIMALS + 
        _depositBalancePerToken.alpha + _depositRebalancingBalancePerToken.alpha;
        _value.beta = (_tokenBalancePerToken.beta * _price[1]) / ParityData.FACTOR_PRICE_DECIMALS + 
        _depositBalancePerToken.beta + _depositRebalancingBalancePerToken.beta;
        _value.gamma = (_tokenBalancePerToken.gamma * _price[2]) / ParityData.FACTOR_PRICE_DECIMALS + 
        _depositBalancePerToken.gamma + _depositRebalancingBalancePerToken.gamma;
        return _value.alpha + _value.beta + _value.gamma;
    }

    function getAvailableTokenValue(ParityData.Event[] memory depositBalancePerTokenPerEvent, 
        ParityData.Event[] memory depositRebalancingBalancePerTokenPerEvent, 
        ParityData.Amount memory tokenBalancePerToken,
        uint256 _indexEvent, 
        uint256[3] memory _price) 
        internal pure returns (uint256){
        ParityData.Amount  memory _value; 
        uint256 _indexDeposit; 
        uint256 _indexRebalancingDeposit;
        _indexDeposit = searchIndexEvent(depositBalancePerTokenPerEvent, _indexEvent);
        _indexRebalancingDeposit = searchIndexEvent(depositRebalancingBalancePerTokenPerEvent, _indexEvent);
        _value = ParityMath.mulMultiCoefDiv2(tokenBalancePerToken, _price, ParityData.FACTOR_PRICE_DECIMALS);
        if (_indexDeposit < MAX_INDEX_EVENT){
            _value = ParityMath.add2( _value, depositBalancePerTokenPerEvent[_indexDeposit].amount);
        }
        if (_indexRebalancingDeposit < MAX_INDEX_EVENT) {
            _value = ParityMath.add2( _value, depositRebalancingBalancePerTokenPerEvent[_indexRebalancingDeposit].amount);
        }
        return _value.alpha + _value.beta + _value.gamma;
    }

    function getTokenValueToRebalance(ParityData.Event[] memory depositBalancePerTokenPerEvent, 
        ParityData.Event[] memory depositRebalancingBalancePerTokenPerEvent,
        ParityData.Amount memory tokenBalancePerToken,
        uint256 _indexEvent,
        uint256[3] memory _price) 
        internal pure returns(uint256, uint256, uint256, uint256){
        uint256 _valueTotal;
        ParityData.Amount  memory _value; 
        uint256 _indexDeposit; 
        uint256 _indexRebalancingDeposit;
        _indexDeposit = searchIndexEvent(depositBalancePerTokenPerEvent, _indexEvent);
        _indexRebalancingDeposit = searchIndexEvent(depositRebalancingBalancePerTokenPerEvent, _indexEvent);
        _value = ParityMath.mulMultiCoefDiv2(tokenBalancePerToken, _price, ParityData.FACTOR_PRICE_DECIMALS);
        if (_indexDeposit < MAX_INDEX_EVENT){
            _value = ParityMath.add2(_value, depositBalancePerTokenPerEvent[_indexDeposit].amount);
        }
        if (_indexRebalancingDeposit < MAX_INDEX_EVENT){
            _value = ParityMath.add2(_value, depositRebalancingBalancePerTokenPerEvent[_indexRebalancingDeposit].amount);
        }
        _valueTotal = _value.alpha + _value.beta + _value.gamma;
        return (_value.alpha,  _value.beta,  _value.gamma, _valueTotal);
    }

    function calculateWithdrawalData(uint256 _rate,  uint256 _totalValue,
        uint256 _depositValueTotal, ParityData.Amount memory _depositValue, 
        ParityData.Amount memory _tokenBalancePerToken, uint256[3] memory _price) 
        internal pure returns ( ParityData.Amount memory _amountToWithdrawFromDeposit,
        ParityData.Amount memory _amountToWithdrawFromTokens){
        ParityData.Amount memory _weights = getWeightsFromToken(_tokenBalancePerToken, _price);
        uint256 _totalAmountToWithdraw;
        uint256 _totalAmountToWithdrawFromDeposit;
        uint256 _totalAmountToWithdrawFromTokens;
        _totalAmountToWithdraw = (_totalValue * _rate);
        _totalAmountToWithdrawFromDeposit = Math.min(_totalAmountToWithdraw, ParityData.COEFF_SCALE_DECIMALS * _depositValueTotal);
        if (_totalAmountToWithdrawFromDeposit > 0){
            _amountToWithdrawFromDeposit.alpha = Math.mulDiv(_totalAmountToWithdrawFromDeposit, _depositValue.alpha, _depositValueTotal);
            _amountToWithdrawFromDeposit.beta = Math.mulDiv(_totalAmountToWithdrawFromDeposit, _depositValue.beta, _depositValueTotal);
            _amountToWithdrawFromDeposit.gamma = Math.min(_totalAmountToWithdrawFromDeposit - (_amountToWithdrawFromDeposit.alpha + _amountToWithdrawFromDeposit.beta), 
            _depositValue.gamma * ParityData.COEFF_SCALE_DECIMALS);
            _amountToWithdrawFromDeposit = ParityMath.div2( _amountToWithdrawFromDeposit, ParityData.COEFF_SCALE_DECIMALS);
        }
        _totalAmountToWithdrawFromTokens = _totalAmountToWithdraw - _totalAmountToWithdrawFromDeposit;
        if (_totalAmountToWithdrawFromTokens >0){
            _amountToWithdrawFromTokens.alpha = (_totalAmountToWithdrawFromTokens * _weights.alpha) ;
            _amountToWithdrawFromTokens.beta = (_totalAmountToWithdrawFromTokens * _weights.beta);
            _amountToWithdrawFromTokens.gamma = Math.min( _totalAmountToWithdrawFromTokens * ParityData.COEFF_SCALE_DECIMALS - (_amountToWithdrawFromTokens.alpha + _amountToWithdrawFromTokens.beta), 
            _totalAmountToWithdrawFromTokens * _weights.gamma);   
        }
    }

    function calculateRebalancingData(uint256 _newDeposit,
        uint256 _valueTotal,
        ParityData.Amount memory _oldValue,
        ParityData.Amount memory _depositBalance, 
        ParityData.Amount memory _weights,
        uint256[3] memory _price) 
        internal pure returns(ParityData.Amount memory _depositToAdd,
        ParityData.Amount memory _depositToRemove,  
        ParityData.Amount memory _depositRebalancing, 
        ParityData.Amount memory _withdrawalRebalancing) { 
        uint256 _newValue;
        _valueTotal += _newDeposit;
        _newValue = Math.mulDiv(_valueTotal, _weights.alpha, ParityData.COEFF_SCALE_DECIMALS);
        (_depositToRemove.alpha, _depositToAdd.alpha,
        _depositRebalancing.alpha, _withdrawalRebalancing.alpha )
        = _calculateRebalancingData (_newValue, _oldValue.alpha, _price[0],
        _newDeposit,  _depositBalance.alpha); 
        _newDeposit -= _depositToAdd.alpha;
        _newValue = Math.mulDiv(_valueTotal, _weights.beta, ParityData.COEFF_SCALE_DECIMALS);
        (_depositToRemove.beta, _depositToAdd.beta,
        _depositRebalancing.beta, _withdrawalRebalancing.beta )
        = _calculateRebalancingData(_newValue, _oldValue.beta, _price[1],
        _newDeposit,  _depositBalance.beta); 
        _newDeposit -= _depositToAdd.beta;
        _newValue = Math.mulDiv(_valueTotal, _weights.gamma, ParityData.COEFF_SCALE_DECIMALS);
        (_depositToRemove.gamma, _depositToAdd.gamma,
        _depositRebalancing.gamma, _withdrawalRebalancing.gamma )
        = _calculateRebalancingData(_newValue, _oldValue.gamma, _price[2],
        _newDeposit,  _depositBalance.gamma); 
        _newDeposit -= _depositToAdd.gamma;    
    }
    
    function _calculateRebalancingData (uint256 _newValue, uint256 _oldValue, 
        uint256 _price,uint256 _newDeposit, uint256 _depositBalance) 
        internal pure  returns (uint256 _depositToRemove,
        uint256 _depositToAdd, uint256 _depositRebalancing,
        uint256 _withdrawalRebalancing) { 
        uint256 _deltaValue;
        if (_newValue < _oldValue){
            _deltaValue = (_oldValue - _newValue);
            _depositToRemove = Math.min(_deltaValue, _depositBalance);
            _deltaValue -= _depositToRemove;
            _withdrawalRebalancing = Math.mulDiv(_deltaValue, ParityData.FACTOR_PRICE_DECIMALS, _price); 
        }
        else{  
            _deltaValue = (_newValue - _oldValue);
            _depositToAdd = Math.min(_newDeposit, _deltaValue);
            _deltaValue -= _depositToAdd;
            _depositRebalancing += _deltaValue;

        }
    }

    function verifyBurnCondition(ParityData.Amount memory _depositBalancePerToken, 
        ParityData.Amount memory _withdrawalBalancePerToken, ParityData.Amount memory _tokenBalancePerToken, 
        ParityData.Amount memory _depositRebalancingBalancePerToken)
        internal pure returns (bool){
        require(_depositBalancePerToken.alpha == 0 
        && _depositBalancePerToken.beta == 0 
        && _depositBalancePerToken.gamma == 0, 
            "Formation.Fi: deposit on pending");
        require(_withdrawalBalancePerToken.alpha == 0
         && _withdrawalBalancePerToken.beta == 0 
        && _withdrawalBalancePerToken.gamma == 0, 
            "Formation.Fi: withdrawal on pending");
        require(_tokenBalancePerToken.alpha == 0 
        && _tokenBalancePerToken.beta == 0 
        && _tokenBalancePerToken.gamma == 0, 
            "Formation.Fi: tokens on pending");
        require(_depositRebalancingBalancePerToken.alpha == 0 
        && _depositRebalancingBalancePerToken.beta == 0 
        && _depositRebalancingBalancePerToken.gamma == 0, 
            "Formation.Fi: deposit rebalancing on pending");
        return true ;
    }

    function isCancelWithdrawalRequest(ParityData.Event[] memory _withdrawalBalancePerTokenPerEvent, uint256 _indexEvent) internal pure
        returns (bool _isCancel, uint256 _index){
          _index = searchIndexEvent(_withdrawalBalancePerTokenPerEvent, _indexEvent);
        if (_index < MAX_INDEX_EVENT){
            if ((_withdrawalBalancePerTokenPerEvent[_index].amount.alpha + 
                _withdrawalBalancePerTokenPerEvent[_index].amount.beta +
                _withdrawalBalancePerTokenPerEvent[_index].amount.gamma) > 0) {
                _isCancel = true;
            }
        }
    }

    function getWeightsFromToken(ParityData.Amount memory _tokenBalancePerToken,  uint256[3] memory _price) 
        internal pure returns (ParityData.Amount memory _weights) {
        uint256 _totalTokenValue = _tokenBalancePerToken.alpha * _price[0] +
        _tokenBalancePerToken.beta * _price[1] + 
        _tokenBalancePerToken.gamma * _price[2];
        if (_totalTokenValue > 0){
            uint256[3] memory _scaledPrice;
            _scaledPrice[0] = _price[0] * ParityData.COEFF_SCALE_DECIMALS;
            _scaledPrice[1] = _price[1] * ParityData.COEFF_SCALE_DECIMALS;
            _scaledPrice[2] = _price[2] * ParityData.COEFF_SCALE_DECIMALS;
            _weights =  ParityMath.mulMultiCoefDiv2(_tokenBalancePerToken, _scaledPrice, _totalTokenValue);
        }
    }

    function getWithdrawalTokenFees(ParityData.Amount memory _fee, ParityData.Amount memory _amountToWithdrawFromTokens ,
        uint256[3] memory _price) internal pure
        returns(ParityData.Amount memory _withdrawalFees){
        _withdrawalFees.alpha = _amountToWithdrawFromTokens.alpha * _fee.alpha;
        _withdrawalFees.beta = _amountToWithdrawFromTokens.beta * _fee.beta;
        _withdrawalFees.gamma = _amountToWithdrawFromTokens.gamma * _fee.gamma;
        uint256[3] memory _scaledPrice;
        uint256 _scale = ParityData.COEFF_SCALE_DECIMALS * ParityData.COEFF_SCALE_DECIMALS * ParityData.COEFF_SCALE_DECIMALS;
        _scaledPrice[0] = _price[0] * _scale;
        _scaledPrice[1] = _price[1] * _scale;
        _scaledPrice[2] = _price[2] * _scale;
        _withdrawalFees = ParityMath.mulDivMultiCoef2(_withdrawalFees, ParityData.FACTOR_PRICE_DECIMALS, _scaledPrice);
    }


    function calculateWithdrawalFees(uint256 _tokenTime, ParityData.Fee[] memory _fee) 
        internal view returns (uint256 _feeRate){
        uint256 _time1;
        uint256 _time2;
        uint256 _value1;
        uint256 _size = _fee.length;
        uint256 _deltaTime = block.timestamp - _tokenTime;
        if ( _size > 0){
            for (uint256 i = 0; i < _size  ; ++i) {
                _value1 = _fee[i].value;
                _time1 = _fee[i].time;
                if (i == _size - 1){
                    _feeRate = 0;
                    break;
                }  
                else {
                    _time2 = _fee[i+1].time;
                    if ((_deltaTime >= _time1) && (_deltaTime < _time2)){
                        _feeRate = _value1;
                        break;
                    }
                }
            }
        }   
    }

    function updateTokenFlowTime( uint256  _oldTokenTime,  
        uint256 _oldTokens, uint256 _newTokens)  
        internal view returns (uint256 _newTokenTime){
        _newTokenTime= (_oldTokens * _oldTokenTime + 
        block.timestamp * _newTokens) / ( _oldTokens + _newTokens);
    }
 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IManagementParity.sol";
import "./IManagementParityParams.sol";

/** 
* @author Formation.Fi.
* @notice Implementation of the contract TokenParityStorage.
*/

contract TokenParityStorage is Ownable {
    ParityData.Amount public depositBalance;
    ParityData.Amount public withdrawalBalance;
    ParityData.Amount public withdrawalRebalancingBalance;
    ParityData.Amount public depositRebalancingBalance;
    address public eventDataParity;
    address public tokenParity;
    address public investmentParity;
    mapping(uint256 => uint256) public optionPerToken;
    mapping(uint256 => uint256) public riskPerToken;
    mapping(uint256 => uint256) public returnPerToken;
    mapping(uint256 => ParityData.Amount) public weightsPerToken;
    mapping(uint256 => ParityData.Amount) public flowTimePerToken;
    mapping(uint256 => ParityData.Amount) public depositBalancePerToken;
    mapping(uint256 => ParityData.Amount) public withdrawalBalancePerToken;
    mapping(uint256 => ParityData.Amount) public depositRebalancingBalancePerToken;
    mapping(uint256 => ParityData.Amount) public withdrawalRebalancingBalancePerToken;
    mapping(uint256 => ParityData.Amount) public tokenBalancePerToken;
    mapping(uint256 => ParityData.Event []) public depositBalancePerTokenPerEvent;
    mapping(uint256 => ParityData.Event []) public withdrawalBalancePerTokenPerEvent;
    mapping(uint256 => ParityData.Event []) public depositRebalancingBalancePerTokenPerEvent;
    mapping(uint256 => ParityData.Event []) public withdrawalRebalancingBalancePerTokenPerEvent;
    mapping(uint256 => ParityData.Event []) public tokenWithdrawalFee;
    IManagementParity public managementParity;
    IManagementParityParams public managementParityParams;
    address public delegateContract;

    constructor (address _delegateContract){
        require(_delegateContract!= address(0),
            "Formation.Fi: zero address");
        uint256 _size;
        assembly{_size := extcodesize(_delegateContract)}
        require (_size > 0, "Formation.Fi: no contract");
        delegateContract = _delegateContract;
    }
  

    modifier onlyManagementParity() {
        require(address(managementParity) != address(0),
            "Formation.Fi: zero address");
        require(msg.sender == address(managementParity), 
            "Formation.Fi: no ManagementParity");
        _;
    }

    modifier onlyEventDataParity() {
        require(eventDataParity != address(0),
            "Formation.Fi: zero address");
        require(msg.sender == eventDataParity, 
            "Formation.Fi: no EventDataParity");
        _;
    }

    function setTokenParity(address _tokenParity) public onlyOwner {
        require(_tokenParity != address(0),
            "Formation.Fi: zero address");
        tokenParity = _tokenParity;
    }

    function setInvestmentParity(address _investmentParity) public onlyOwner {
        require(_investmentParity != address(0),
            "Formation.Fi: zero address");
        investmentParity =  _investmentParity;
    }


    function setmanagementParity(address _managementParity, address _managementParityParams, 
    address _eventDataParity) 
    public onlyOwner {
        require(_managementParity != address(0),
            "Formation.Fi: zero address");
        require(_eventDataParity != address(0),
            "Formation.Fi: zero address");
        require(_managementParityParams != address(0),
            "Formation.Fi: zero address");
        managementParity = IManagementParity(_managementParity);
        managementParityParams = IManagementParityParams(_managementParityParams);
        eventDataParity = _eventDataParity;
    }
    function setDelegateContract(address _delegateContract) external onlyOwner {
        require(_delegateContract != address(0),
            "Formation.Fi: zero address");
        uint256 _size;
        assembly{_size := extcodesize(_delegateContract)}
        require (_size > 0, "Formation.Fi: no contract");
        delegateContract =  _delegateContract;
    }

    function updateTokenBalancePerToken(uint256 _tokenId, uint256 _amount, uint256 _id) 
        external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("updateTokenBalancePerToken(uint256,uint256,uint256)",
        _tokenId,  _amount,  _id));
        require (success == true, "Formation.Fi: delegatecall fails");    
    } 

    function updateDepositBalancePerToken(uint256 _tokenId, uint256 _amount, 
        uint256 _indexEvent, uint256 _id) external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("updateDepositBalancePerToken(uint256,uint256,uint256,uint256)",
        _tokenId,  _amount, _indexEvent,_id));
        require (success == true, "Formation.Fi: delegatecall fails");   
    }   

    function updateRebalancingDepositBalancePerToken(uint256 _tokenId, uint256 _amount, 
        uint256 _indexEvent,uint256 _id) external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("updateRebalancingDepositBalancePerToken(uint256,uint256,uint256,uint256)",
        _tokenId,  _amount, _indexEvent,_id));
        require (success == true, "Formation.Fi: delegatecall fails");    
    }   

    function updateRebalancingWithdrawalBalancePerToken(uint256 _tokenId, uint256 _amount, 
        uint256 _indexEvent,uint256 _id) external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("updateRebalancingWithdrawalBalancePerToken(uint256,uint256,uint256,uint256)",
        _tokenId,  _amount, _indexEvent,_id));
        require (success == true, "Formation.Fi: delegatecall fails");
    }   

    function updateWithdrawalBalancePerToken(uint256 _tokenId, uint256 _amount, 
        uint256 _indexEvent, uint256 _id) external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("updateWithdrawalBalancePerToken(uint256,uint256,uint256,uint256)",
        _tokenId,  _amount, _indexEvent,_id));
        require (success == true, "Formation.Fi: delegatecall fails");
        
    }   

    function updateTotalBalances(ParityData.Amount memory _depositAmount, 
        ParityData.Amount memory _withdrawalAmount, 
        ParityData.Amount memory _depositRebalancingAmount, 
        ParityData.Amount memory _withdrawalRebalancingAmount) 
        external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("updateTotalBalances((uint256,uint256,uint256),(uint256,uint256,uint256),(uint256,uint256,uint256),(uint256,uint256,uint256))",
        _depositAmount, _withdrawalAmount, _depositRebalancingAmount, _withdrawalRebalancingAmount)); 
        require (success == true, "Formation.Fi: delegatecall fails");
    }  

    function rebalanceParityPosition( ParityData.Position memory _position,
        uint256 _indexEvent, uint256[3] memory _price, bool _isFree) 
        external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("rebalanceParityPosition((uint256,uint256,uint256,uint256,uint256,(uint256,uint256,uint256)),uint256,uint256[3],bool)",
        _position, _indexEvent,  _price,  _isFree)); 
        require (success == true, "Formation.Fi: delegatecall fails");  
    }
    
    function cancelWithdrawalRequest (uint256 _tokenId, uint256 _indexEvent, 
        uint256[3] memory _price) external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("cancelWithdrawalRequest(uint256,uint256,uint256[3])",
        _tokenId, _indexEvent,  _price)); 
        require (success == true, "Formation.Fi: delegatecall fails"); 
    }

    function withdrawalRequest (uint256 _tokenId, uint256 _indexEvent, 
        uint256 _rate, uint256[3] memory _price, address _owner) external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("withdrawalRequest(uint256,uint256,uint256,uint256[3],address)",
        _tokenId, _indexEvent, _rate,  _price, _owner)); 
        require (success == true, "Formation.Fi: delegatecall fails"); 
    }

    function updateUserPreference(ParityData.Position memory _position, 
        uint256 _indexEvent, uint256[3] memory _price,  bool _isFirst) 
        external {
        (bool success, ) = delegateContract.delegatecall(abi.encodeWithSignature("updateUserPreference((uint256,uint256,uint256,uint256,uint256,(uint256,uint256,uint256)),uint256,uint256[3],bool)", _position, _indexEvent, _price, _isFirst)); 
        require (success == true, "Formation.Fi: delegatecall fails");
    }

    function getDepositBalancePerTokenPerEvent(uint256 _tokenId) public view 
        returns(ParityData.Event[] memory){
        uint256 _size = depositBalancePerTokenPerEvent[_tokenId].length;
        ParityData.Event[] memory _data = new ParityData.Event[](_size);
        for (uint256 i = 0; i < _size ; ++i) {  
            _data[i] = depositBalancePerTokenPerEvent[_tokenId][i];
        }
        return _data;
    }
    
    function getDepositRebalancingBalancePerTokenPerEvent(uint256 _tokenId) public view 
        returns(ParityData.Event[] memory){
        uint256 _size = depositRebalancingBalancePerTokenPerEvent[_tokenId].length;
        ParityData.Event[] memory _data = new ParityData.Event[](_size);
        for (uint256 i = 0; i < _size ; ++i) {  
            _data[i] = depositRebalancingBalancePerTokenPerEvent[_tokenId][i];
        }
        return _data;
    }
    function getWithdrawalBalancePerTokenPerEvent(uint256 _tokenId) public view 
        returns(ParityData.Event[] memory){
        uint256 _size = withdrawalBalancePerTokenPerEvent[_tokenId].length;
        ParityData.Event[] memory _data = new ParityData.Event[](_size);
        for (uint256 i = 0; i < _size ; ++i) {  
            _data[i] = withdrawalBalancePerTokenPerEvent[_tokenId][i];
        }
        return _data;
    }

    function getWithdrawalRebalancingBalancePerTokenPerEvent(uint256 _tokenId) public view 
        returns(ParityData.Event[] memory){
        uint256 _size = withdrawalRebalancingBalancePerTokenPerEvent[_tokenId].length;
        ParityData.Event[] memory _data = new ParityData.Event[](_size);
        for (uint256 i = 0; i < _size ; ++i) {  
            _data[i] = withdrawalRebalancingBalancePerTokenPerEvent[_tokenId][i];
        }
        return _data;
    }
   
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./ParityData.sol"; 
library ParityMath {
    function add(ParityData.Amount storage _var1, ParityData.Amount memory _var2) internal {
        _var1.alpha = _var1.alpha + _var2.alpha;
        _var1.beta = _var1.beta + _var2.beta;
        _var1.gamma = _var1.gamma + _var2.gamma;
    }

    function sub(ParityData.Amount storage _var1, ParityData.Amount memory _var2) internal {
        require((_var1.alpha >= _var2.alpha ) &&
        (_var1.beta >= _var2.beta ) &&
        (_var1.gamma >= _var2.gamma ), "Formation.Fi: negative number");
        _var1.alpha = _var1.alpha - _var2.alpha;
        _var1.beta = _var1.beta - _var2.beta;
        _var1.gamma = _var1.gamma - _var2.gamma;
    }


    function add2(ParityData.Amount memory _var1, ParityData.Amount memory _var2) internal pure
        returns (ParityData.Amount memory _var) {
        _var.alpha = _var1.alpha + _var2.alpha;
        _var.beta = _var1.beta + _var2.beta;
        _var.gamma = _var1.gamma + _var2.gamma;
    }

    function sub2(ParityData.Amount memory _var1, ParityData.Amount memory _var2) internal pure
        returns (ParityData.Amount memory _var) {
        require((_var1.alpha >= _var2.alpha ) &&
        (_var1.beta >= _var2.beta ) &&
        (_var1.gamma >= _var2.gamma ), "Formation.Fi: negative number");
        _var.alpha = _var1.alpha - _var2.alpha;
        _var.beta = _var1.beta - _var2.beta;
        _var.gamma = _var1.gamma - _var2.gamma;
    }


    function mul(ParityData.Amount storage _var1, uint256 _coef) internal {
        _var1.alpha = _var1.alpha * _coef ;
        _var1.beta =  _var1.beta * _coef ;
        _var1.gamma = _var1.gamma * _coef ;
    }

    function div2(ParityData.Amount memory _var1, uint256 _coef) internal pure
        returns (ParityData.Amount memory _var) {
        _var.alpha =  _var1.alpha /_coef ;
        _var.beta =  _var1.beta /_coef;
        _var.gamma =  _var1.gamma /_coef;
    }

    function mulMultiCoef(ParityData.Amount storage _var1, uint256[3] memory _coef) internal {
        _var1.alpha = _coef[0] * _var1.alpha;
        _var1.beta = _coef[1] * _var1.beta;
        _var1.gamma = _coef[2] * _var1.gamma;
    }

    function mulMultiCoef2(ParityData.Amount memory _var1, uint256[3] memory _coef) internal pure
        returns (ParityData.Amount memory _var) {
        _var.alpha = _coef[0] * _var1.alpha;
        _var.beta = _coef[1] * _var1.beta;
        _var.gamma = _coef[2] * _var1.gamma;
    }

    function mulDiv(ParityData.Amount storage _var1, uint256 _mulcoef, uint256 _divcoef) internal {
        _var1.alpha = Math.mulDiv(_var1.alpha, _mulcoef, _divcoef);
        _var1.beta = Math.mulDiv(_var1.beta, _mulcoef, _divcoef);
        _var1.gamma = Math.mulDiv(_var1.gamma, _mulcoef, _divcoef);
    }

    function mulDiv2(ParityData.Amount memory _var1, uint256 _mulcoef, uint256 _divcoef) internal pure 
        returns (ParityData.Amount memory _var) {
        _var.alpha = Math.mulDiv(_var1.alpha, _mulcoef, _divcoef);
        _var.beta = Math.mulDiv(_var1.beta, _mulcoef, _divcoef);
        _var.gamma = Math.mulDiv(_var1.gamma, _mulcoef, _divcoef);
    }

    function mulMultiCoefDiv(ParityData.Amount storage _var1, uint256[3] memory _mulcoef, uint256 _divcoef) internal{
        _var1.alpha = Math.mulDiv(_var1.alpha, _mulcoef[0], _divcoef);
        _var1.beta = Math.mulDiv(_var1.beta, _mulcoef[1], _divcoef);
        _var1.gamma = Math.mulDiv(_var1.gamma, _mulcoef[2], _divcoef);
    }

    function mulDivMultiCoef(ParityData.Amount storage _var1, uint256 _mulcoef, uint256[3] memory _mulDiv) internal{
        _var1.alpha = Math.mulDiv(_var1.alpha, _mulcoef, _mulDiv[0]);
        _var1.beta = Math.mulDiv(_var1.beta, _mulcoef, _mulDiv[1]);
        _var1.gamma = Math.mulDiv(_var1.gamma, _mulcoef, _mulDiv[2]);
    }

    function mulMultiCoefDiv2(ParityData.Amount memory _var1, uint256[3] memory _mulcoef, uint256 _divcoef) internal pure
        returns (ParityData.Amount memory _var){
        _var.alpha = Math.mulDiv(_var1.alpha, _mulcoef[0], _divcoef);
        _var.beta =  Math.mulDiv(_var1.beta, _mulcoef[1], _divcoef);
        _var.gamma = Math.mulDiv(_var1.gamma, _mulcoef[2], _divcoef);

    }
    function mulDivMultiCoef2(ParityData.Amount memory _var1, uint256 _mulcoef, uint256[3] memory _mulDiv) internal pure 
        returns (ParityData.Amount memory _var) {
        _var.alpha = Math.mulDiv(_var1.alpha, _mulcoef, _mulDiv[0]);
        _var.beta = Math.mulDiv(_var1.beta, _mulcoef, _mulDiv[1]);
        _var.gamma = Math.mulDiv(_var1.gamma, _mulcoef, _mulDiv[2]);
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
library ParityData {
    uint256 public constant COEFF_SCALE_DECIMALS = 1e18;
    uint256 public constant FACTOR_PRICE_DECIMALS = 1e18;

    struct Amount {
        uint256 alpha;
        uint256 beta;
        uint256 gamma;
    }

    struct Position {
        uint256 tokenId;
        uint256 amount;
        uint256 userOption;
        uint256 userRisk;
        uint256 userReturn;
        Amount userWeights;
    }

    struct Fee {
        uint256 value;
        uint256 time;
    }

    struct Event {
        Amount amount;
        uint256 index;
    }

    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../main/libraries/SafeBEP20.sol";
import "./libraries/ParityData.sol"; 

interface IManagementParity {
    function sendTokenFee(ParityData.Amount memory _fee) external;
    function sendStableFee(address _account, uint256 _amount,  uint256 _fee) external;
    function indexEvent() external view returns (uint256);
    function sendBackWithdrawalFee(ParityData.Amount memory) external;
    function getStableBalance() external view returns (uint256) ;
    function getDepositFee(uint256 _amount) external view  returns (uint256);
    function getMinAmountDeposit() external view returns (uint256);
    function getTreasury() external view returns (address);
    function isManager(address _address) external view returns (bool);
    function getToken() external view returns (IBEP20, IBEP20, IBEP20);
    function getStableToken() external view returns(IBEP20);
    function amountScaleDecimals() external view returns(uint256);
    function getPrice() external view returns(uint256[3] memory);
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../main/libraries/SafeBEP20.sol";
import "./libraries/ParityData.sol"; 

interface IManagementParityParams {
    function getDepositFee(uint256 _amount) external view returns(uint256);
    function depositMinAmount() external view returns(uint256);
    function treasury() external view returns(address);
    function manager() external view returns(address);
    function isManager(address _account) external view returns(bool);
    function getWithdrawalVariableFeeData()external view  returns(ParityData.Fee[] memory);
    function fixedWithdrawalFee() external view  returns(uint256);
    function getRebalancingFee(uint256 _value) external view returns(uint256);
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../IBEP20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}