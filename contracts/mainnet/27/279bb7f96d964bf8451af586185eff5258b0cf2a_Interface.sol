/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;
interface RF{
    function setOperator(address _operator) external;
    function setSlippage(uint256 _value) external;
    function setVswapPaths(
        address _inputToken,
        address _outputToken,
        address[] memory _path
    ) external;
    struct FarmInfo {
        address farmAddress;     
        uint256[] PoolIds;       
    }
    function farmInfo(uint value) external view returns(FarmInfo memory);
    function setUnirouterPath(
        address _input,
        address _output,
        address[] memory _path
    ) external;

    function grantFund(
        address _token,
        uint256 _amount,
        address _to
    ) external;
    
    
    function exchangeRate(
        address _inputToken,
        address _outputToken,
        uint256 _tokenAmount
    ) external view returns (uint256);

    function getTokenToBnbPrice(address _token) external view returns (uint256);
    function pancakeSwapToken(
        address _inputToken,
        address _outputToken,
        uint256 _amount
    ) external;

    function otherAddLiquidity(
        address _lp,
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _minToMint
    ) external;
    function pancakeAddLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired
    ) external;

    function pancakeRemoveLiquidity(address _pair, uint256 _liquidity) external;
    function vswapSwapToken(
        address _inputToken,
        address _outputToken,
        uint256 _amount
    ) external;
    function vswapAddLiquidity(
        address _pair,
        uint256 _amountADesired,
        uint256 _amountBDesired
    ) external;

    function vswapAddAllLiquidity(address _pair) external;

    function vswapRemoveLiquidity(address _pair, uint256 _liquidity) external;
    function vswapRemoveAllLiquidity(address _pair) external ;

    function deposit(
        address _pool,
        uint256 _pid,
        address _lpAdd,
        uint256 _amount
    ) external;
    function depositToPool(
        address _pool,
        uint256 _pid,
        address _lpAdd,
        uint256 _lpAmount
    ) external;

    function depositAllToPool(
        address _pool,
        uint256 _pid,
        address _lpAdd
    ) external;

    function withdrawFrom(
        address _pool,
        uint256 _pid,
        uint256 _lpAmount
    ) external;

    function withdrawAllFrom(address _pool, uint256 _pid) external;
    function havestAll(uint256 _farmId) external;
    function claimFrom(address _pool, uint256[] memory _pid) external;
    function pendingFrom(address _pool, uint256 _pid) external view returns (uint256);

    function stakeAmount(address _pool, uint256 _pid) external view returns (uint256 _stakedAmount);
}

contract Interface{
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    // governance
    address public operator;
   
    modifier onlyOperator() {
        require(operator == msg.sender, "!operator");
        _;
    }

    constructor () {
        operator = msg.sender;
        
    }
    /* ========== GOVERNANCE ========== */

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }
    function setSlippage(address target, uint256 _value) external onlyOperator {
         RF(target).setSlippage(_value);
    }
    function setVswapPaths(address target,
        address _inputToken,
        address _outputToken,
        address[] memory _path
    ) external onlyOperator {
        RF(target).setVswapPaths( _inputToken, _outputToken, _path);
    }

    function setUnirouterPath(address target,
        address _input,
        address _output,
        address[] memory _path
    ) external onlyOperator {
        RF(target).setUnirouterPath(_input, _output, _path);
    }

    function grantFund(address target, 
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        RF(target).grantFund(_token, _amount, _to);
    }
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Pancake: TRANSFER_FAILED');
    }
    function withdrawEth(uint value) external onlyOperator{
        address to = msg.sender;
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
    
    function withdraw(address token, uint amount) external onlyOperator {
        _safeTransfer(token, msg.sender, amount);
    }
    /* ========== VIEW FUNCTIONS ========== */

    
    function exchangeRate(address target,
        address _inputToken,
        address _outputToken,
        uint256 _tokenAmount
    ) public view returns (uint256) {
        return RF(target).exchangeRate(_inputToken, _outputToken, _tokenAmount);
    }

    function getTokenToBnbPrice(address target, address _token) public view returns (uint256) {
        return RF(target).getTokenToBnbPrice(_token);
    }
    function getIds(address target, uint Id) public view returns (uint256[] memory) {
        return RF(target).farmInfo(Id).PoolIds;
    }
   
    /* ========== MUTATIVE FUNCTIONS ========== */

    function pancakeSwapToken(address target, 
        address _inputToken,
        address _outputToken,
        uint256 _amount
    ) external onlyOperator {
        RF(target).pancakeSwapToken(_inputToken, _outputToken, _amount);
    }

    function otherAddLiquidity(address target, 
        address _lp,
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _minToMint
    ) external onlyOperator {
        RF(target).otherAddLiquidity(_lp, _tokenA, _tokenB, _amountADesired, _amountBDesired, _minToMint);
    }
    function pancakeAddLiquidity(address target, 
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired
    ) external onlyOperator {
        RF(target).pancakeAddLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired);
    }

    function pancakeRemoveLiquidity(address target, address _pair, uint256 _liquidity) external onlyOperator {
        RF(target).pancakeRemoveLiquidity(_pair, _liquidity);
    }

    function vswapSwapToken(address target, 
        address _inputToken,
        address _outputToken,
        uint256 _amount
    ) external onlyOperator {
        RF(target).vswapSwapToken(_inputToken, _outputToken, _amount);
    }

    function vswapAddLiquidity(address target, 
        address _pair,
        uint256 _amountADesired,
        uint256 _amountBDesired
    ) external onlyOperator {
        RF(target).vswapAddLiquidity(_pair, _amountADesired, _amountBDesired);
    }

    function vswapAddAllLiquidity(address target, address _pair) external onlyOperator {
        RF(target).vswapAddAllLiquidity(_pair);
    }

    function vswapRemoveLiquidity(address target, address _pair, uint256 _liquidity) external onlyOperator {
        RF(target).vswapRemoveLiquidity(_pair, _liquidity);
    }

    function vswapRemoveAllLiquidity(address target, address _pair) external onlyOperator {
        RF(target).vswapRemoveAllLiquidity(_pair);
    }

    function deposit(address target, 
        address _pool,
        uint256 _pid,
        address _lpAdd,
        uint256 _amount
    ) public onlyOperator {
        //transfer from sender to target
        RF(target).deposit(_pool, _pid,_lpAdd, _amount);
    }
    function depositToPool(address target, 
        address _pool,
        uint256 _pid,
        address _lpAdd,
        uint256 _lpAmount
    ) public onlyOperator {
        RF(target).depositToPool(_pool, _pid,_lpAdd, _lpAmount);
    }

    function depositAllToPool(address target, 
        address _pool,
        uint256 _pid,
        address _lpAdd
    ) external onlyOperator {
        RF(target).depositAllToPool(_pool, _pid, _lpAdd);
    }

    function withdrawFrom(address target, 
        address _pool,
        uint256 _pid,
        uint256 _lpAmount
    ) public onlyOperator {
        RF(target).withdrawFrom(_pool, _pid, _lpAmount);
    }

    function withdrawAllFrom(address target, address _pool, uint256 _pid) external onlyOperator {
        RF(target).withdrawAllFrom( _pool,  _pid);
    }
    function havestAll(address target, uint256 _farmId) external onlyOperator{
       RF(target). havestAll(_farmId);
    }
    function havest(address target, uint256 Id, uint[] memory ids) external onlyOperator{
        address f = (RF(target).farmInfo(Id).farmAddress);
        claimFrom(target, f, ids);
    }
    function claimFrom(address target, address _pool, uint256[] memory _pid) public onlyOperator {
        RF(target).claimFrom(_pool, _pid);
    }
     function pendindAll(address target, uint Id) public view returns (uint256) {
         uint tot;
         address f = (RF(target).farmInfo(Id).farmAddress);
         uint[] memory ids =RF(target).farmInfo(Id).PoolIds;
         for(uint i=0;i<ids.length;i++){
            tot+= pendingFrom(target, f, ids[i]);
         }
        return tot;
    }
    function pendingFrom(address target, address _pool, uint256 _pid) public view returns (uint256) {
        return RF(target).pendingFrom(_pool, _pid);
    }

    function stakeAmount(address target, address _pool, uint256 _pid) external view returns (uint256) {
        return RF(target).stakeAmount(_pool, _pid);
    }
    

    receive() external payable {}
}