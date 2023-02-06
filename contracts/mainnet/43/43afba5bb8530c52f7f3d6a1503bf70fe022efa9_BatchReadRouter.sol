/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
// import all dependencies and interfaces:

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}



interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint256 reserve0, uint256 reserve1, uint32 blockTimestampLast);
}


interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
}


interface INomiswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint256 reserve0, uint256 reserve1, uint32 blockTimestampLast);
    function swapFee() external view returns (uint256 fee);
}


interface ICurvePair {
    function initial_A() external view returns (uint256);
    function future_A() external view returns (uint256);
    function initial_A_time() external view returns (uint256);
    function future_A_time() external view returns (uint256);
    function balances(uint256) external view returns (uint256);
}


interface IPmmPair {
    function _BASE_TOKEN_() external view returns (address);
    function _QUOTE_TOKEN_() external view returns (address);
    function _BASE_BALANCE_() external view returns (uint256);
    function _QUOTE_BALANCE_() external view returns (uint256);
    function getExpectedTarget() external view returns (uint256 baseTarget, uint256 quoteTarget);
    function _K_() external view returns (uint256);
    function _LP_FEE_RATE_() external view returns (uint256);
    function _MT_FEE_RATE_() external view returns (uint256);
    function getOraclePrice() external view returns (uint256) ;
    function _R_STATUS_() external view returns (uint8);
}


interface IVault {
    enum PoolSpecialization { GENERAL, MINIMAL_SWAP_INFO, TWO_TOKEN }
    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );
    function getPool(bytes32 poolId) external view returns (address, PoolSpecialization);
}

interface IWeightedPool {
    function getNormalizedWeights() external view returns (uint256[] memory);
}

interface IStablePool {
     function getAmplificationParameter()
        external
        view
        returns (
            uint256 value,
            bool isUpdating,
            uint256 precision
        );
}


contract BatchReadRouter {
    // AMM /////////////////
    function multiGetReservesWithTimestamp(  
        address[] memory pairs
    ) public view returns(uint[] memory, uint[] memory,uint[] memory ){
        uint256 count = pairs.length; 
        uint[] memory reservesA = new uint[](count);
        uint[] memory reservesB = new uint[](count);
        uint[] memory timestampes = new uint[](count);
        for( uint16 i=0 ; i <  count ; i++ ){
            (reservesA[i], reservesB[i],timestampes[i]) = IUniswapV2Pair(pairs[i]).getReserves();
        }
        return (reservesA, reservesB,timestampes);
    }

    // Nomiswap /////////////////
    function multiGetNomiswapBalances(  
        address[] memory pairs
    ) public view returns(uint[] memory,uint[] memory,uint[] memory,uint[] memory ){
        uint256 count = pairs.length; 
        uint[] memory reservesA = new uint[](count);
        uint[] memory reservesB = new uint[](count);
        uint[] memory timestampes = new uint[](count);
        uint[] memory swapFees = new uint[](count);
        for( uint16 i=0 ; i <  count ; i++ ){
            (reservesA[i], reservesB[i],timestampes[i]) = INomiswapV2Pair(pairs[i]).getReserves();
            swapFees[i] = INomiswapV2Pair(pairs[i]).swapFee();
        }
        return (reservesA,reservesB,timestampes,swapFees);
    }
    ////////////////////////

    // Curve /////////////////
    function multiGetCurveBalances(  
        address[] memory pairs,
        uint256[] memory nCoins
    ) public view returns(uint256[][] memory , uint256[][] memory){
        uint256 count = pairs.length; 

        uint256[][] memory allBalanceValues = new uint256[][](count);
        uint256[][] memory allAValues = new uint256[][](count);
        
        for( uint16 i = 0 ; i < count ; i++){
            uint256[] memory pairBalanceValues = new uint256[](nCoins[i]);
            uint256[] memory pairAValues = new uint256[](4);
            uint z = 0;
            for(uint256 j = 0; j < nCoins[i] ; j++){
                pairBalanceValues[j] = ICurvePair(pairs[i]).balances(j);
            }  
            pairAValues[z] = ICurvePair(pairs[i]).initial_A();
            z++;
            pairAValues[z] = ICurvePair(pairs[i]).initial_A_time();
            z++;
            pairAValues[z] = ICurvePair(pairs[i]).future_A();
            z++;
            pairAValues[z] = ICurvePair(pairs[i]).future_A_time();

            allBalanceValues[i] = pairBalanceValues;
            allAValues[i] = pairAValues;

        }
        return (allBalanceValues, allAValues);
    }
    ////////////////////////

    // PMM /////////////////
    function multiGetPmmValues(
        address[] memory pairs
    )  public view returns(address[][] memory res1, uint256[][] memory res2) {
        uint256 count = pairs.length;
        res1 = new address[][](2);
        res2 = new uint256[][](9);
        address[] memory baseToken = new address[](count);
        address[] memory quoteToken = new address[](count);
        uint256[] memory baseBalance = new uint256[](count);
        uint256[] memory quoteBalance = new uint256[](count);
        uint256[] memory expectedTargetBase = new uint256[](count);
        uint256[] memory expectedTargetQuote = new uint256[](count);
        uint256[] memory k = new uint256[](count);
        uint256[] memory lpFeeRate = new uint256[](count);
        uint256[] memory mtFeeRate = new uint256[](count);
        uint256[] memory oraclePrice = new uint256[](count);
        uint256[] memory rStatus = new uint256[](count);
        for( uint16 i = 0; i < count; i++){
            baseToken[i] = IPmmPair(pairs[i])._BASE_TOKEN_();
            quoteToken[i] = IPmmPair(pairs[i])._QUOTE_TOKEN_();
            baseBalance[i] = IPmmPair(pairs[i])._BASE_BALANCE_();
            quoteBalance[i] = IPmmPair(pairs[i])._QUOTE_BALANCE_();
            (expectedTargetBase[i] ,expectedTargetQuote[i] ) = IPmmPair(pairs[i]).getExpectedTarget();
            k[i] = IPmmPair(pairs[i])._K_();
            lpFeeRate[i] = IPmmPair(pairs[i])._LP_FEE_RATE_();
            mtFeeRate[i] = IPmmPair(pairs[i])._MT_FEE_RATE_();
            oraclePrice[i] = IPmmPair(pairs[i]).getOraclePrice();
            rStatus[i] = IPmmPair(pairs[i])._R_STATUS_();
        }
        res1[0] = baseToken;
        res1[1] = quoteToken;
        res2[0] = baseBalance;
        res2[1] = quoteBalance;
        res2[2] = expectedTargetBase;
        res2[3] = expectedTargetQuote;
        res2[4] = k;
        res2[5] = lpFeeRate;
        res2[6] = mtFeeRate;
        res2[7] = oraclePrice;
        res2[8] = rStatus;

        return (res1,res2);
    }
    ////////////////////////

    function multiGetBalanceWallets(  
        address[] memory tokens,
        address[] memory wallet_addresses
    ) public view returns(uint[][] memory){
        uint256 token_count = tokens.length; 
        uint256 wallet_count = wallet_addresses.length; 
        uint[][] memory wallets = new uint[][](wallet_count);
        for (uint16 i = 0; i < wallet_count; i++){
            uint[] memory balances = new uint[](token_count);
            for( uint16 j=0 ; j <  token_count ; j++ ){
                balances[j] = IERC20(tokens[j]).balanceOf(wallet_addresses[i]);
            }
            wallets[i] = balances;
        }
        return wallets;
    }

    struct PairObj {
        address pair_address;
        address token0;
        address token1;
    }

    function getAllFactoryPairs(
        address factory_address,
        uint256 skip,
        uint256 limit
    ) public view returns(PairObj[] memory){

        uint256 j = 0;
        uint256 count = limit  - skip;
        IUniswapV2Factory factory = IUniswapV2Factory(factory_address);
        PairObj[] memory pairs = new PairObj[](count);
        for(uint256 i = skip ; i < limit ; i ++){
            address pair_address = factory.allPairs(i);
            IUniswapV2Pair pair_obj = IUniswapV2Pair(pair_address);
            pairs[j] = PairObj(
                pair_address,
                pair_obj.token0(),
                pair_obj.token1()
            );
            j++;
        }
        return pairs;
    }

    ///////////////////////////////////////////////////
    ///////////////////////////////////////////////////
    function burnRate(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    ) public returns (uint256 pre_balance, uint256 post_balance) {
        pre_balance = token.balanceOf(recipient);
        token.transferFrom(sender, recipient, amount);
        post_balance = token.balanceOf(recipient);
    }

    function hasPermit(
        IERC20 token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (uint256) {
        token.permit(owner, spender, amount, deadline, v, r, s);
        return token.allowance(owner, spender);
    }

    struct VaultPairsList {
        address[] pair_address;
    }

    function getAllVaultPairs(address[] calldata vault_address, bytes32[][] calldata poolId) 
        public 
        view 
        returns(VaultPairsList[] memory)
    {
        uint256 vCount = vault_address.length;
        
        VaultPairsList[] memory vaultPairs = new VaultPairsList[](vCount);
    
        for(uint256 i = 0 ; i < vCount ; i++){
            IVault v = IVault(vault_address[i]);
            uint256 pCount = poolId[i].length;
            address[] memory x = new address[](pCount);
            for(uint256 j = 0 ; j < pCount ; j++){
                (x[j], ) = v.getPool(poolId[i][j]);
            }
            vaultPairs[i] = VaultPairsList(x);
        }
        return vaultPairs;
    }

    struct VaultWeightedPoolValues {
        uint256[] normalizedWeights;
    }
    struct VaultStablePoolValues {
        uint256 value;
        bool isUpdating;
        uint256 precision;
    }
    struct VaultPoolTokens {
        address[] tokens;
        uint256[] balances;
        uint256 lastChangeBlock;
    }
    struct VaultValues {
        VaultPoolTokens vaultPoolTokens;
        VaultWeightedPoolValues vaultWeightedPoolValues;
        VaultStablePoolValues vaultStablePoolValues;
    }

    function vaultReserves(address[] calldata vault_address, bytes32[][][] calldata poolsId, address[][][] calldata pairsAddress, uint256 count, uint256 typeNo)
        public
        view
        returns (VaultValues[] memory)
    {
        VaultValues[] memory result = new VaultValues[](count);
        uint256 a;
        a = 0;

        for(uint256 i = 0 ; i < vault_address.length ; i++){
            for(uint256 j = 0 ; j < typeNo ; j++){ 
                for(uint256 k = 0 ; k < poolsId[i][j].length ; k++){ 
                    result[a].vaultPoolTokens = _vaultReserves(vault_address[i], poolsId[i][j][k]);
                    if(j == 0){
                        result[a].vaultWeightedPoolValues = _vaultWeightedValues(pairsAddress[i][j][k]);
                    } else if(j == 1){
                        result[a].vaultStablePoolValues = _vaultStableValues(pairsAddress[i][j][k]);
                    }
                    a++;
                }
            }
        }
        return result;
    }

    function _vaultReserves(address vault, bytes32 poolId)
        internal
        view
        returns (VaultPoolTokens memory)
    {
        address[] memory tokens;
        uint256[] memory balances;
        uint256 lastChangeBlock;
        VaultPoolTokens memory result;

        (tokens, balances, lastChangeBlock) = IVault(vault).getPoolTokens(poolId);

        result = VaultPoolTokens(
        tokens,
        balances,
        lastChangeBlock
        );  
        return result;
    }

    function _vaultWeightedValues(address pairAddress)
        internal
        view
        returns (VaultWeightedPoolValues memory)
    {
        uint256[] memory normalizedWeights;
        VaultWeightedPoolValues memory result;          
        normalizedWeights = IWeightedPool(pairAddress).getNormalizedWeights();
        result = VaultWeightedPoolValues(normalizedWeights);           
        return result;
    }

    function _vaultStableValues(address pairAddress)
        internal
        view
        returns (VaultStablePoolValues memory)
    {
        uint256 value = 0;
        bool isUpdating = false;
        uint256 precision = 0;
        VaultStablePoolValues memory result;
                    
        (value, isUpdating, precision) = IStablePool(pairAddress).getAmplificationParameter();
        result = VaultStablePoolValues(
        value,
        isUpdating,
        precision
        );  
                    
        return result;
    }

}