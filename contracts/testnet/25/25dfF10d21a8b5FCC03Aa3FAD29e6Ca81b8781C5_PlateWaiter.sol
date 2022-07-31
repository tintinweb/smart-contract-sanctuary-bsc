// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./BaseWaiter.sol";

//TODO: use AccessControl?
contract PlateWaiter is BaseWaiter {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IVaultRegistry immutable public vaultRegistry;

    constructor( 
        address _weth,
        address[] memory _routers,
        address _vaultRegistry) 
    BaseWaiter(_weth,_routers)
    { 
        require(_vaultRegistry != address(0), "VAULT_REGISTRY_ZERO");
        vaultRegistry = IVaultRegistry(_vaultRegistry);
    }

  /* ==========  Swaps  ========== */

    function serveFromInputAmt(address _inputToken, address _vault, uint256 _amountIn, uint256 _amountOutMin) 
    external {
        // transfer input tokens from msgsender to waiter
        IERC20 inputToken = IERC20(_inputToken);
        require(inputToken.balanceOf(_msgSender()) >= _amountIn, "Insufficient Input Token");
        inputToken.safeTransferFrom(_msgSender(), address(this), _amountIn);

        // swap to output
        swapFromInputAmt(_inputToken, _vault, _amountIn, _amountOutMin);

        // return vault output to user
        IERC20 outputToken = IERC20(_vault);
        uint256 outputAmount = outputToken.balanceOf(address(this));
        outputToken.safeTransfer(_msgSender(), outputAmount);

        // return remainingInputAmount (due to excess method used in non-mirror strategy of serveVaultFromInputAmt)
        uint256 remainingInputAmount = inputToken.balanceOf(address(this));
        inputToken.safeTransfer(_msgSender(), remainingInputAmount);
    }

    function serveToOutputAmt( address _inputToken, address _vault, uint256 _amountInMax, uint256 _amountOut) 
    external {
        IERC20 inputToken = IERC20(_inputToken);
        require(inputToken.balanceOf(_msgSender()) >= _amountInMax, "Insufficient Input Token");
        inputToken.safeTransferFrom(_msgSender(), address(this), _amountInMax);

        // swap to output
        swapForOutputAmt(_inputToken, _vault, _amountInMax, _amountOut);

        // return vault output to user
        IERC20 outputToken = IERC20(_vault);
        uint256 outputAmount = outputToken.balanceOf(address(this));
        outputToken.safeTransfer(_msgSender(), outputAmount);

        uint256 remainingInputAmount = inputToken.balanceOf(address(this));
        inputToken.safeTransfer(_msgSender(), remainingInputAmount);
    }
    //TODO: complete swap portion
    function serveFromEthInputAmt(address _vault, uint256 _ethAmountIn, uint256 _amountOutMin) 
    external {
        // transfer gas over
        IWETH(address(WETH)).deposit{value: _ethAmountIn}();
        require(WETH.balanceOf(address(this)) >= _ethAmountIn, "Insufficient Input Amount");

        // swap
        uint256 outputAmount = swapFromInputAmt(address(WETH), _vault, _ethAmountIn, _amountOutMin);

        //Return Vault Output to User
        IERC20 outputToken = IERC20(_vault);
        outputToken.safeTransfer(_msgSender(), outputAmount);
    }
    //TODO: complete swap portion
    function serveToEthOutputAmt(address _vault, uint256 _ethAmountInMax, uint256 _amountOut) 
    external {
        IWETH(address(WETH)).deposit{value: _ethAmountInMax}();
        require(WETH.balanceOf(address(this)) >= _ethAmountInMax, "Insufficient Input Amount");

        // swap
        uint256 outputAmount = swapForOutputAmt(address(WETH), _vault, _ethAmountInMax, _amountOut);

        // Return Vault Output to User
        IERC20 outputToken = IERC20(_vault);
        outputToken.safeTransfer(_msgSender(), outputAmount);

        uint256 remainingInputAmount = WETH.balanceOf(address(this));
        WETH.safeTransfer(_msgSender(), remainingInputAmount);
    }

    // swaping based on weth. TODO: change to determined base
    function swapFromInputAmt(address _inputToken, address _outputToken, uint256 _amountIn, uint256 _amountOutMin) 
    internal returns(uint256){
        if(_inputToken == _outputToken){
            return _amountIn;
        }

        // if input is not WETH swap to WETH? then swap to output
        if(_inputToken != address(WETH)){
            uint256 wethAmount = swapViaBestRouterFromInputAmt(_inputToken, address(WETH), _amountIn, 1);
            //uint256 memory wethAmount = WETH.balanceOf(this);
            return swapFromInputAmt(address(WETH), _outputToken, wethAmount, _amountOutMin);
        }

        if(vaultRegistry.inRegistry(_outputToken)) {
            return serveVaultFromInputAmt(address(WETH), _outputToken, _amountIn, _amountOutMin);
        }

        // else normal swap
        return swapViaBestRouterFromInputAmt(_inputToken, _outputToken, _amountIn, _amountOutMin);
    }

    function swapForOutputAmt(address _inputToken, address _outputToken, uint256 _amountInMax, uint256 _amountOut) 
    internal returns(uint256){
        if(_inputToken == _outputToken){
            return _amountOut;
        }

        // if input is not WETH swap to WETH? then swap to output
        if(_inputToken != address(WETH)){
            // this swap is deliberate not via output determined due to lack of knowledge of WETH amount
            uint256 wethAmount = swapViaBestRouterFromInputAmt(_inputToken, address(WETH), _amountInMax, 1);
            return swapForOutputAmt(address(WETH), _outputToken, wethAmount, _amountOut);
        }

        if(vaultRegistry.inRegistry(_outputToken)) {
            return serveVaultForOutputAmt(address(WETH), _outputToken, _amountInMax, _amountOut);
        }

        // else normal swap
        return swapViaBestRouterForOutputAmt(_inputToken, _outputToken, _amountInMax, _amountOut);
    }

    function serveVaultFromInputAmt(address _inputToken, address _vault, uint256 _amountIn, uint256 _amountOutMin) 
    internal returns(uint256){
        //uses WETH input by default
        require(vaultRegistry.inRegistry(_vault), "OUTPUT TOKEN NOT A VAULT");
        IVault vault = IVault(_vault);
        
        // if(_inputToken!=address(WETH)){
        //     _amountIn = swapFromInputAmt(_inputToken, address(WETH), _amountIn, 1);
        // }

        // simulate the amount of each pool input token canditate required (interms of _inputToken) for 1 unit Vault output
        (address[] memory uintInputtokens, uint256[] memory uintInputAmounts) = vault.calcTokensForAmount(10**18);
        
        uint256 totalUnitInputAmount = this.convertInputTokensToTotalOutputAmt(
                                                uintInputtokens,
                                                uintInputAmounts,
                                                _inputToken
                                                );

        uint256[] memory unitInputArray = this.convertInputTokensToOutputAmtArray(
                                                uintInputtokens,
                                                uintInputAmounts,
                                                _inputToken
                                                );
        
        uint256[] memory swappedInputTokens = new uint256[](uintInputtokens.length);
        for(uint256 i = 0; i < uintInputtokens.length; i ++) {
            uint256 inputPortion = _amountIn.mul(unitInputArray[i]).div(totalUnitInputAmount);
            swappedInputTokens[i] = swapViaBestRouterFromInputAmt(_inputToken, uintInputtokens[i], 
                                        inputPortion, 
                                        1);
        }

        uint256 minPoolAmount;
        for(uint256 i = 0; i < uintInputtokens.length; i ++) {
            uint256 determinedPoolamt;
            determinedPoolamt = swappedInputTokens[i].div(uintInputAmounts[i]).mul(10**18);
            if (minPoolAmount == 0 || determinedPoolamt < minPoolAmount) {
                minPoolAmount = determinedPoolamt;
            }

            // Approve amount for joinpool swapping (Note there might be excess amount due to slippage)
            IERC20 token = IERC20(uintInputtokens[i]);
            token.approve(_vault, 0);
            //uint256 swappedAmt = token.balanceOf(address(this));
            //token.approve(_vault, swappedAmt);
            token.approve(_vault, swappedInputTokens[i]);
        }

        require(minPoolAmount>= _amountOutMin, "Vault Serve: Underswapped Output Minimum.");
        vault.joinPool(minPoolAmount, false);
        return minPoolAmount;
    }

    function serveVaultForOutputAmt(address _inputToken, address _vault, uint256 _amountInMax, uint256 _amountOut) 
    internal returns(uint256){
        //uses WETH input by default
        require(vaultRegistry.inRegistry(_vault), "OUTPUT TOKEN NOT A VAULT");
        IVault vault = IVault(_vault);
        (address[] memory tokens, uint256[] memory amounts) = vault.calcTokensForAmount(_amountOut);
        
        uint256 totalused = 0;
        for(uint256 i = 0; i < tokens.length; i ++) {
            totalused += swapViaBestRouterForOutputAmt(_inputToken, tokens[i], type(uint256).max, amounts[i]);
            IERC20 token = IERC20(tokens[i]);
            token.approve(_vault, 0);
            token.approve(_vault, amounts[i]);
            //totalWETHused += wethused;
        }
        require(totalused <= _amountInMax, "Vault Serve: Overused Input Maximum.");
        vault.joinPool(_amountOut, false);
        return totalused;
    }

    function redeemVaultToTokens(address _vault, address _outputToken, uint256 _amountIn, uint256 _amountOutMin) 
    external returns(uint256){
        IVault vault = IVault(_vault);
        IERC20 vaultToken = IERC20(_vault);

        require(vaultToken.balanceOf(_msgSender())>= _amountIn, "Insufficient Input Tokens");
        vaultToken.safeTransferFrom(_msgSender(), address(this), _amountIn);
        vault.exitPool(_amountIn);

        address[] memory tokens = vault.getTokens();
        for(uint i=0; i<tokens.length; i++){
            //check wherther the iterated token is the desired one
            if(tokens[i] != _outputToken){
                swapViaBestRouterFromInputAmt(tokens[i], _outputToken, IERC20(tokens[i]).balanceOf(address(this)), 1);
            }
        }

        uint256 outputAmount = IERC20(_outputToken).balanceOf(address(this));
        require(outputAmount>=_amountOutMin, "Slippage cause insufficient redeem output");
        emit OutputAmount(outputAmount);
        IERC20(_outputToken).safeTransfer(_msgSender(), outputAmount);
    }

    // TODO: No redeem Vault with specific amountOut in mind.

  /* ==========  View Functions  ========== */
    // former getPrice
    function getKitchenInputAmt(address _inputToken, address _outputToken, uint256 _amountOut) 
    public view returns(uint256)  {
        if(_inputToken == _outputToken) {
                return _amountOut;
            }

        if(customHops[_outputToken] != address(0)) {
            //get price for hop
            uint256 hopAmount = getKitchenInputAmt(customHops[_inputToken], _outputToken, _amountOut);
            return getKitchenInputAmt(_inputToken, customHops[_inputToken], hopAmount); //edit original customHop code
        }

        // check if input token is vault (redeem swap)?
        if(vaultRegistry.inRegistry(_inputToken)) {
            
            if (_outputToken != address(WETH)){
                _amountOut = getKitchenInputAmt(address(WETH), _outputToken, _amountOut);
            }

            // get weth amount for 1 token redeem
            uint256 wETHamtForUnitTokenRedeem = getETHamtFromVaultExit(_inputToken, 10**18);

            uint256 amountIn = _amountOut.div(wETHamtForUnitTokenRedeem).mul(10**18);

            return amountIn;
        }

        // check if output token is vault
        if(vaultRegistry.inRegistry(_outputToken)) {
            uint256 ethAmount =  getETHamtForVaultOutput(_outputToken, _amountOut);

            // if input was not WETH
            if(_inputToken != address(WETH)) {
                return getKitchenInputAmt(_inputToken, address(WETH), ethAmount);
            }

            return ethAmount;
        }

        // if input and output are not WETH (2 hop swap)
        if(_inputToken != address(WETH) && _outputToken != address(WETH)) {
            (uint256 middleInputAmount,) = getBestDexFromOutput(address(WETH), _outputToken, _amountOut);
            (uint256 inputAmount,) = getBestDexFromOutput(_inputToken, address(WETH), middleInputAmount);

            return inputAmount;
        }

        // else single hop swap (either input or output is weth)
        (uint256 inputAmount,) = getBestDexFromOutput(_inputToken, _outputToken, _amountOut);

        return inputAmount;
    }
    
    // former getOutputAmount
    function getKitchenOutputAmt(address _inputToken, address _outputToken, uint256 _amountIn) 
    public view returns(uint256)  {
        if(_inputToken == _outputToken) {
                return _amountIn;
            }
            
        if(customHops[_inputToken] != address(0)) {
            //get amount for hop
            uint256 hopAmount = getKitchenOutputAmt(_inputToken, customHops[_inputToken], _amountIn);
            return getKitchenOutputAmt(customHops[_inputToken], _outputToken, hopAmount);
        }

        // deal if input is Vault Token
        if(vaultRegistry.inRegistry(_inputToken)){
            uint256 wethAmount = getETHamtFromVaultExit(_inputToken, _amountIn);
            if(_outputToken == address(WETH)){
                return wethAmount;
            }
            return getKitchenOutputAmt(address(WETH), _outputToken, wethAmount);
        }
        
        // deal if outputToken is Vault Token
        if(vaultRegistry.inRegistry(_outputToken)) {
            // Convert Input to WETH
            uint256 wethAmount = _amountIn;
            if(_inputToken !=address(WETH)){
                wethAmount = getKitchenOutputAmt(_inputToken, address(WETH), _amountIn);
            }

            // Check theoretical amount that will be converted
            IVault vault = IVault(_outputToken);
            address[] memory tokens = vault.getTokens();
            //uint256 vaultweight = vault.getVaultWeight();
            uint256 vaultweight = vault.VAULT_WEIGHT();
            //uint256 entryFee = vault.getEntryFee();
            uint256 entryFee = vault.entryFee();
            

            //denominate all to weth proportions
            uint256 wethPortions = 0;
            for (uint256 i = 0; i < tokens.length; i ++) {
                uint256 wethRatio = getKitchenOutputAmt(tokens[i], address(WETH), 10**18)
                                    ; //1 token portion of WETH

                uint256 feeAmount = wethRatio.mul(entryFee).div(10**18);
                wethPortions += wethRatio //absolute ratio of 1 weth 
                        .add(feeAmount) //interms of vaultweight
                        //.mul(vault.getTokenWeight(tokens[i])) 
                        .mul(vault.tokenWeight(tokens[i])) 
                        .div(vaultweight); //normalize to 1 vault
            }

            require(wethPortions > 0, "Invalid Basket Allocations");
            uint256 vaultOutputAmount = _amountIn.div(wethPortions).mul(10**18); //amount must be in weth!
            return vaultOutputAmount;
        }

        // if input and output are not WETH (2 hop swap)
        if(_inputToken != address(WETH) && _outputToken != address(WETH)) {
            (uint256 middleInputAmount,) = getBestDexFromInput(_inputToken, address(WETH), _amountIn);
            (uint256 outputAmount,) = getBestDexFromInput(address(WETH), _outputToken, middleInputAmount);

            return outputAmount;
        }

        // else if input is WETH or output is WETH, single hop swap
        (uint256 outputAmount,) = getBestDexFromInput(_inputToken, _outputToken, _amountIn);

        return outputAmount;
    }

    // NOTE input token must be WETH
    function getETHamtForVaultOutput(address _vault, uint256 _amountOut) internal view returns(uint256) {
        IVault vault = IVault(_vault);
        (address[] memory tokens, uint256[] memory amounts) = vault.calcTokensForAmount(_amountOut);

        uint256 inputAmount = 0;

        for(uint256 i = 0; i < tokens.length; i ++) {
            inputAmount += getKitchenInputAmt(address(WETH), tokens[i], amounts[i]);
        }

        return inputAmount;
    }

    function getETHamtFromVaultExit(address _vault, uint256 _amountIn) public view returns(uint256){
        IVault vault = IVault(_vault);
        (address[] memory tokens, uint256[] memory amounts) = vault.calcTokensForAmountExit(_amountIn);

        uint256 outputAmount=0;
        
        for(uint256 i =0; i< tokens.length; i++){
            outputAmount += getKitchenOutputAmt(tokens[i], address(WETH), amounts[i]);
        }

        return outputAmount;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


import "../interfaces/IWETH.sol";
import "../interfaces/IVaultRegistry.sol";
import { IPVault as IVault } from "../interfaces/IPVault.sol";
import "../interfaces/IUniRouter.sol";

//TODO: use AccessControl?
contract BaseWaiter is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 immutable public WETH;
    address[] public routers; // change to array (assumes all dex routers uses same interface as uni)

  /* ==========  EVENTS  ========== */
    event OutputAmount(uint256 _amount);

  /* ==========  Storage  ========== */
    mapping(address => address) public customHops;

    struct SwapResults {
        uint256 amt;
        address router;
    }

    constructor(
        address _weth,
        address[] memory _routers
    ) { 
        require(_weth != address(0), "WETH_ZERO");

        WETH = IERC20(_weth);

        require(_routers.length > 0, "NO_ROUTER_IN_INPUT_ARRAY");
        for (uint256 i=0; i<_routers.length; i++){
            require(_routers[i] != address(0), "ROUTER_ZERO_ADDRESS");
        }
        routers = _routers;
    }
  /* ==========  Swaps  ========== */
    function swapViaBestRouterFromInputAmt(address _inputToken, address _outputToken, uint256 _amountIn, uint256 _amountOutMin) 
    internal returns(uint256) {
        //returns output amount
        if(address(_inputToken) == _outputToken) {
            return _amountIn;
        }

        // deal with custom hops
        if(customHops[_outputToken] != address(0)) {
            //swap to intermediate hop first
            uint256 hopAmount = swapViaBestRouterFromInputAmt(_inputToken, customHops[_inputToken], _amountIn, 1);
            return swapViaBestRouterFromInputAmt(customHops[_inputToken], _outputToken, hopAmount, _amountOutMin);
        }

        // get best dex and theoretical outputAmount
        (, address dex) = getBestDexFromInput(_inputToken, _outputToken, _amountIn);

        // swap using best router
        address[] memory route = getRoute(_inputToken, _outputToken);
        IERC20 inputToken = IERC20(_inputToken);
        inputToken.approve(dex, 0);
        inputToken.approve(dex, type(uint256).max);
        return IUniRouter(dex).swapExactTokensForTokens(_amountIn, _amountOutMin, route, address(this), block.timestamp + 1)[0];
    }

    function swapViaBestRouterForOutputAmt(address _inputToken, address _outputToken, uint256 _amountInMax, uint256 _amountOut) 
    internal returns(uint256) {
        //returns input amount
        if(address(_inputToken) == _outputToken) {
            return _amountOut;
        }

        if(customHops[_outputToken] != address(0)) {
            //swap to intermediate hop first //TODO: Check logic
            uint256 hopAmount = swapViaBestRouterForOutputAmt(_inputToken, customHops[_outputToken], _amountInMax, type(uint256).max);
            return swapViaBestRouterForOutputAmt(customHops[_outputToken], _outputToken, hopAmount, _amountOut);
        }

        ( , address dex) = getBestDexFromOutput(_inputToken, _outputToken, _amountOut); //inputAmount not used!

        address[] memory route = getRoute(_inputToken, _outputToken);
        // swap using best router
        IERC20 inputToken = IERC20(_inputToken);
        inputToken.approve(dex, 0);
        inputToken.approve(dex, type(uint256).max);
        return IUniRouter(dex).swapTokensForExactTokens(_amountOut, _amountInMax, route, address(this), block.timestamp + 1)[0];
    }

  /* ==========  View Functions  ========== */
    function getRoute(address _inputToken, address _outputToken) public view returns(address[] memory route) {
            // if both input and output are not WETH
            if(_inputToken != address(WETH) && _outputToken != address(WETH)) {
                route = new address[](3);
                route[0] = _inputToken;
                route[1] = address(WETH);
                route[2] = _outputToken;
                return route;
            }

            route = new address[](2);
            route[0] = _inputToken;
            route[1] = _outputToken;

            return route;
    }

  // former getPriceUniLike
    function getDexOutputAmt(address _inputToken, address _outputToken, uint256 _inputAmount, IUniRouter _router) internal view returns(uint256) {
        if(_inputToken == _outputToken) {
            return(_inputAmount);
        }

        try _router.getAmountsOut(_inputAmount, getRoute(_inputToken, _outputToken)) returns(uint256[] memory amounts) {
            return amounts[1];
        } catch {
            return 0;
        }
    }

  // former getAmountUniLike
    function getDexInputAmt(address _inputToken, address _outputToken, uint256 _outputAmount, IUniRouter _router) 
    internal view returns(uint256){
        if(_inputToken == _outputToken) {
                return(_outputAmount);
        }
            
        // TODO this IS an external call but somehow the compiler does not recognize it as such :(
        try _router.getAmountsIn(_outputAmount, getRoute(_inputToken, _outputToken)) returns(uint256[] memory amounts) {
            return amounts[0];
        } catch {
            return type(uint256).max;
        }
    }

  // former getBestAmountSushiUni
    function getBestDexFromInput(address _inputToken, address _outputToken, uint256 _amountIn) 
    public view returns(uint256, address) {
        require(routers.length>0, "NO ROUTERS IN ARRAY");
        
        if (routers.length==1){
            return (
                getDexOutputAmt(_inputToken, _outputToken, _amountIn, IUniRouter(routers[0])), routers[0]
            );
        }

        SwapResults[] memory results;
        for (uint256 i=0; i< routers.length; i++){
            uint256 amt = getDexOutputAmt(_inputToken, _outputToken, _amountIn, IUniRouter(routers[i]));
            results[results.length]=SwapResults(amt, routers[i]); //cannot use push due to memory view
        }
        // Sort to get largest amount if there are 2 results or more
        if (results.length>1){
            for (uint256 i=1; i< results.length; i++){
                if(results[i-1].amt > results[i].amt){
                    results[i] = results[i-1]; //push highest result to last
                }
            }
        }        
        return (results[results.length - 1].amt, results[results.length - 1].router);
    }
  // former getBestPriceSushiUni
    function getBestDexFromOutput(address _inputToken, address _outputToken, uint256 _amountOut) 
    public view returns(uint256, address) {
        require(routers.length>0, "NO ROUTERS IN ARRAY");
        // if only 1 router, then bypass other code to save gas
        if (routers.length==1){
            return (
                getDexInputAmt(_inputToken, _outputToken, _amountOut, IUniRouter(routers[0])), routers[0]
            );
        }

        SwapResults[] memory results;
        for (uint256 i=0; i< routers.length; i++){
            uint256 amt = getDexInputAmt(_inputToken, _outputToken, _amountOut, IUniRouter(routers[i]));
            results[results.length] = SwapResults(amt, routers[i]);  // cannot use push here due to memory view
        }
        // Sort to get smallest amount if there are 2 results
        if (results.length>1){
            for (uint256 i=1; i< results.length; i++){
                if(results[i-1].amt < results[i].amt){
                    results[i] = results[i-1]; //push lowest result to last
                }
            }
        }        
        return (results[results.length - 1].amt, results[results.length - 1].router);
        
    }

    function convertInputTokensToOutputAmtArray(
        address[] memory _inputTokens, 
        uint256[] memory _amountsIn, 
        address _outputToken)
    external view returns(uint256[] memory outputAmounts)
    {
        require(_inputTokens.length > 0, "Missing Input Tokens.");
        require(_inputTokens.length == _amountsIn.length, "Unequal input array lengths.");
        uint256[] memory outputAmounts = new uint256[](_inputTokens.length);
        for (uint256 i = 0; i < _inputTokens.length; i ++){
            (outputAmounts[i], ) = getBestDexFromInput(_inputTokens[i], _outputToken, _amountsIn[i]);
        }
        return outputAmounts;
    }

    function convertInputTokensToTotalOutputAmt(
        address[] memory _inputTokens, 
        uint256[] memory _amountsIn, 
        address _outputToken)
    external view returns(uint256 outputAmount)
    {
        require(_inputTokens.length > 0, "Missing Input Tokens.");
        require(_inputTokens.length == _amountsIn.length, "Unequal input array lengths.");
        uint256 outputAmount=0;
        for (uint256 i = 0; i < _inputTokens.length; i ++){
            (uint256 outAmt, ) = getBestDexFromInput(_inputTokens[i], _outputToken, _amountsIn[i]);
            outputAmount += outAmt;
        }
        return outputAmount;
    }

  /* ========== bytecode utils ========== */
    function encodeData(uint256 _amount) external pure returns(bytes memory){
            return abi.encode((_amount));
    }

  /* ==========  Configuration Actions  ========== */

    function setCustomHop(address _token, address _hop) external onlyOwner {
        customHops[_token] = _hop;
    }

    function addRouter(address _router) external onlyOwner {
        require(_router != address(0), "ROUTER_ZERO_ADDRESS");
        routers.push(_router);
    }
    function removeRouter(address _router) external onlyOwner {
        require(routers.length>1, "ROUTERS ARRAY WILL BE EMPTY");
        for(uint256 i; i < routers.length; i ++) {
            if(address(routers[i]) == _router) {
                routers[i] = routers[routers.length - 1]; //replace with last router
                routers.pop();
                // event?
                break;
            }
        }
    }

    function saveToken(address _token, address _to, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }

    function saveEth(address payable _to, uint256 _amount) external onlyOwner {
        _to.call{value: _amount}("");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
interface IVaultRegistry {
    function inRegistry(address _pool) external view returns(bool);
    function entries(uint256 _index) external view returns(address);
    function addVault(address _vault) external;
    function removeVault(uint256 _index) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPVault is IERC20 {
    
    function mint(uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns (bool);

    function joinPool(uint256 _amount, bool _lending) external returns (uint256);

    function exitPool(uint256 _amount) external returns(uint256);

    function calcOutStandingAnnualizedFee() external view returns(uint256);

    function chargeOutstandingAnnualizedFee() external;

    /* ==========  View Functions  ========== */

    function VAULT_WEIGHT() external view returns (uint256);

    function entryFee() external view returns (uint256);

    function tokenWeight(address) external view returns (uint256);

    function getLock() external view returns(bool);

    function balance(address _token) external view returns(uint256);

    function getTokens() external view returns (address[] memory);

    function calcTokensForAmount(uint256 _amount) external view 
        returns (address[] memory, uint256[] memory);

    function calcTokensForAmountExit(uint256 _amount) external view 
        returns (address[] memory tokensArray, uint256[] memory amounts);

    function getTokenInPool(address _token) external view returns(bool);

    /* ==========  Configs  ========== */
    function setLock(uint256 _lock) external;

    function setEntryFee(uint256 _fee) external;

    function setExitFee(uint256 _fee) external;

    function setAnnualizedFee(uint256 _fee) external;
    
    function setFeeBeneficiary(address _beneficiary) external;

    function setEntryFeeBeneficiaryShare(uint256 _share) external;

    function setExitFeeBeneficiaryShare(uint256 _share) external;

    function setCap(uint256 _maxCap) external;

    function setMinBalanceAmt(uint256 _minBal) external;

    function addToken(address _token) external;

    function removeToken(address _token) external;

    function setTokenWeight(address _token, uint256 _weight) external;

    function setLendingRegistry(address _lendingRegistry) external;

    function setLendingManager(address _lendingManager) external;

    function setUnderlyingToProtocol(address _underlying, bytes32 _protocol) external;

    function removeProtocolFromUnderlying(address _underlying) external;

    function addCaller(address _caller) external;

    function removeCaller(address _caller) external;

    /* ==========  Call Functions  ========== */
    function call(address[] memory _targets, bytes[] memory _calldata, uint256[] memory _values) external;

    function callNoValue(address[] memory _targets, bytes[] memory _calldata) external;

    function singleCall(address _target, bytes calldata _calldata, uint256 _value) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IUniswapV2Router01 {
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
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniRouter is IUniswapV2Router01 {
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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