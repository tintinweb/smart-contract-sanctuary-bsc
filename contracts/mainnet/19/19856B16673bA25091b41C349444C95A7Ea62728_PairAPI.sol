// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;


import '../libraries/Math.sol';
import '../interfaces/IBribeFull.sol';
import '../interfaces/IWrappedBribeFactory.sol';
import '../interfaces/IGauge.sol';
import '../interfaces/IGaugeFactory.sol';
import '../interfaces/IERC20.sol';
import '../interfaces/IMinter.sol';
import '../interfaces/IPair.sol';
import '../interfaces/IPairFactory.sol';
import '../interfaces/IVoter.sol';
import '../interfaces/IVotingEscrow.sol';


contract PairAPI {


    struct pairInfo {
        // pair info
        address pair_address; 			// pair contract address
        string symbol; 				    // pair symbol
        string name;                    // pair name
        uint decimals; 			        // pair decimals
        bool stable; 				    // pair pool type (stable = false, means it's a variable type of pool)
        uint total_supply; 			    // pair tokens supply
    
        // token pair info
        address token0; 				// pair 1st token address
        string token0_symbol; 			// pair 1st token symbol
        uint token0_decimals; 		    // pair 1st token decimals
        uint reserve0; 			        // pair 1st token reserves (nr. of tokens in the contract)
        uint claimable0;                // claimable 1st token from fees (for unstaked positions)

        address token1; 				// pair 2nd token address
        string token1_symbol;           // pair 2nd token symbol
        uint token1_decimals;    		// pair 2nd token decimals
        uint reserve1; 			        // pair 2nd token reserves (nr. of tokens in the contract)
        uint claimable1; 			    // claimable 2nd token from fees (for unstaked positions)

        // pairs gauge
        address gauge; 				    // pair gauge address
        uint gauge_total_supply; 		// pair staked tokens (less/eq than/to pair total supply)
        address fee; 				    // pair fees contract address
        address bribe; 				    // pair bribes contract address
        address wrapped_bribe; 			// pair wrapped bribe contract address
        uint emissions; 			    // pair emissions (per second)
        address emissions_token; 		// pair emissions token address
        uint emissions_token_decimals; 	// pair emissions token decimals

        // User deposit
        uint account_lp_balance; 		// account LP tokens balance
        uint account_token0_balance; 	// account 1st token balance
        uint account_token1_balance; 	// account 2nd token balance
        uint account_gauge_balance;     // account pair staked in gauge balance
        uint account_gauge_earned; 		// account earned emissions for this pair
    }


    struct tokenBribe {
        address token;
        uint8 decimals;
        uint256 amount;
        string symbol;
    }
    

    struct pairBribeEpoch {
        uint256 epochTimestamp;
        uint256 totalVotes;
        address pair;
        tokenBribe[] bribes;
    }

    uint256 public constant MAX_PAIRS = 1000;
    uint256 public constant MAX_EPOCHS = 200;
    uint256 public constant MAX_REWARDS = 16;
    uint256 public constant WEEK = 7 * 24 * 60 * 60;


    IPairFactory public pairFactory;
    IVoter public voter;
    IWrappedBribeFactory public wBribeFactory;

    address public underlyingToken;

    address public owner;


    event Owner(address oldOwner, address newOwner);
    event Voter(address oldVoter, address newVoter);
    event WBF(address oldWBF, address newWBF);

    constructor(address _voter, address _wBribeFactory) {
        owner = msg.sender;

        voter = IVoter(_voter);

        wBribeFactory = IWrappedBribeFactory(_wBribeFactory);

        require(wBribeFactory.voter() == address(voter), '!= voters');

        voter = IVoter(_voter);
        pairFactory = IPairFactory(voter.factory());
        underlyingToken = IVotingEscrow(voter._ve()).token();
        
    }



    function getAllPair(address _user, uint _amounts, uint _offset) external view returns(pairInfo[] memory Pairs){


        require(_amounts <= MAX_PAIRS, 'too many pair');

        Pairs = new pairInfo[](_amounts);
        
        uint i = _offset;
        uint totPairs = pairFactory.allPairsLength();
        address _pair;

        for(i; i < _offset + _amounts; i++){
            // if totalPairs is reached, break.
            if(i == totPairs) {
                break;
            }
            _pair = pairFactory.allPairs(i);
            Pairs[i - _offset] = _pairAddressToInfo(_pair, _user);
        }        

    }

    function getPair(address _pair, address _account) external view returns(pairInfo memory _pairInfo){
        return _pairAddressToInfo(_pair, _account);
    }

    function _pairAddressToInfo(address _pair, address _account) internal view returns(pairInfo memory _pairInfo) {

        IPair ipair = IPair(_pair);
        
        address token_0;
        address token_1;
        uint r0;
        uint r1;
        
        (token_0, token_1) = ipair.tokens();
        (r0, r1, ) = ipair.getReserves();

        IGauge _gauge = IGauge(voter.gauges(_pair));
        uint accountGaugeLPAmount = 0;
        uint earned = 0;
        uint gaugeTotalSupply = 0;
        uint emissions = 0;

        if(address(_gauge) != address(0)){
            accountGaugeLPAmount = _gauge.balanceOf(_account);
            earned = _gauge.earned(underlyingToken, _account);
            gaugeTotalSupply = _gauge.totalSupply();
            emissions = _gauge.rewardRate(underlyingToken);
        }
        
        // Pair General Info
        _pairInfo.pair_address = _pair;
        _pairInfo.symbol = ipair.symbol();
        _pairInfo.name = ipair.name();
        _pairInfo.decimals = ipair.decimals();
        _pairInfo.stable = ipair.isStable();
        _pairInfo.total_supply = ipair.totalSupply();        

        // Token0 Info
        _pairInfo.token0 = token_0;
        _pairInfo.token0_decimals = IERC20(token_0).decimals();
        _pairInfo.token0_symbol = IERC20(token_0).symbol();
        _pairInfo.reserve0 = r0;
        _pairInfo.claimable0 = ipair.claimable0(_account);

        // Token1 Info
        _pairInfo.token1 = token_1;
        _pairInfo.token1_decimals = IERC20(token_1).decimals();
        _pairInfo.token1_symbol = IERC20(token_1).symbol();
        _pairInfo.reserve1 = r1;
        _pairInfo.claimable1 = ipair.claimable1(_account);

        // Pair's gauge Info
        _pairInfo.gauge = address(_gauge);
        _pairInfo.gauge_total_supply = gaugeTotalSupply;
        _pairInfo.emissions = emissions;
        _pairInfo.emissions_token = underlyingToken;
        _pairInfo.emissions_token_decimals = IERC20(underlyingToken).decimals();

        // external address
        _pairInfo.fee = voter.internal_bribes(address(_gauge)); 				    
        _pairInfo.bribe = voter.external_bribes(address(_gauge)); 				    
        _pairInfo.wrapped_bribe = wBribeFactory.oldBribeToNew( voter.external_bribes(address(_gauge)) ); 			


        // Account Info
        _pairInfo.account_lp_balance = IERC20(_pair).balanceOf(_account);
        _pairInfo.account_token0_balance = IERC20(token_0).balanceOf(_account);
        _pairInfo.account_token1_balance = IERC20(token_1).balanceOf(_account);
        _pairInfo.account_gauge_balance = accountGaugeLPAmount;
        _pairInfo.account_gauge_earned = earned;
        

    }

    function getPairBribe(uint _amounts, uint _offset, address _pair) external view returns(pairBribeEpoch[] memory _pairEpoch){

        require(_amounts <= MAX_EPOCHS, 'too many epochs');

        _pairEpoch = new pairBribeEpoch[](_amounts);

        address _gauge = voter.gauges(_pair);
        IBribeFull bribe  = IBribeFull(voter.external_bribes(_gauge));
        address _wbribe = wBribeFactory.oldBribeToNew( voter.external_bribes(address(_gauge)) );

        // check bribe and checkpoints exists
        if(address(0) == address(bribe)){
            return _pairEpoch;
        }
        uint256 supplyNumCheckpoints = bribe.supplyNumCheckpoints();
        if(supplyNumCheckpoints == 0){
            return _pairEpoch;
        }

        // scan bribes starting from last, we do not know init timestamp.
        // get latest balance and epoch start for bribes
        uint _epochEndTimestamp;
        uint _epochStartTimestamp;
        uint _supplyIndex;
        uint _timestamp;
        uint _supply;

        uint _start = block.timestamp + 7 * 86400;
        uint i = _offset;
        for(i; i < _offset + _amounts; i++){
            
            _epochEndTimestamp      = bribe.getEpochStart(_start) - 1;
            _supplyIndex            = bribe.getPriorSupplyIndex(_epochEndTimestamp);
            (_timestamp,_supply)    = bribe.supplyCheckpoints(_supplyIndex);
            _epochStartTimestamp    = bribe.getEpochStart(_timestamp);


            _pairEpoch[i-_offset].epochTimestamp = _epochStartTimestamp;
            _pairEpoch[i-_offset].pair = _pair;
            _pairEpoch[i-_offset].totalVotes = _supply;
            _pairEpoch[i-_offset].bribes = _bribe(_epochStartTimestamp, _wbribe);

            _start -= WEEK; 

        }

    }

    function _bribe(uint _ts, address _br) internal view returns(tokenBribe[] memory _tb){

        IBribeFull _wb = IBribeFull(_br);
        uint tokenLen = _wb.rewardsListLength();

        _tb = new tokenBribe[](tokenLen);

        uint k;
        uint _rewPerEpoch;
        IERC20 _t;
        for(k = 0; k < tokenLen; k++){
            _t = IERC20(_wb.rewards(k));
            _rewPerEpoch = _wb.tokenRewardsPerEpoch(address(_t), _ts);
            if(_rewPerEpoch > 0){
                _tb[k].token = address(_t);
                _tb[k].symbol = _t.symbol();
                _tb[k].decimals = _t.decimals();
                _tb[k].amount = _rewPerEpoch;
            } else{
                _tb[k].token = address(_t);
                _tb[k].symbol = _t.symbol();
                _tb[k].decimals = _t.decimals();
                _tb[k].amount = 0;
            }
        }
    }


    function setOwner(address _owner) external {
        require(msg.sender == owner, 'not owner');
        require(_owner != address(0), 'zeroAddr');
        owner = _owner;
        emit Owner(msg.sender, _owner);
    }


    function setVoter(address _voter) external {
        require(msg.sender == owner, 'not owner');
        require(_voter != address(0), 'zeroAddr');
        address _oldVoter = address(voter);
        voter = IVoter(_voter);
        
        require(wBribeFactory.voter() == address(voter), '!= voters');

        // update variable depending on voter
        pairFactory = IPairFactory(voter.factory());
        underlyingToken = IVotingEscrow(voter._ve()).token();

        emit Voter(_oldVoter, _voter);
    }

    
    function setWrappedBribeFactory(address _wBribeFactorywBribeFactory) external {
        require(msg.sender == owner, 'not owner');
        require(_wBribeFactorywBribeFactory != address(0), 'zeroAddr');
        
        address _oldwBribeFactory = address(wBribeFactory);
        wBribeFactory = IWrappedBribeFactory(_wBribeFactorywBribeFactory);
        
        require(wBribeFactory.voter() == address(voter), '!= voters');

        emit WBF(_oldwBribeFactory, _wBribeFactorywBribeFactory);
    }


}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library Math {
    function max(uint a, uint b) internal pure returns (uint) {
        return a >= b ? a : b;
    }
    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    function cbrt(uint256 n) internal pure returns (uint256) { unchecked {
        uint256 x = 0;
        for (uint256 y = 1 << 255; y > 0; y >>= 3) {
            x <<= 1;
            uint256 z = 3 * x * (x + 1) + 1;
            if (n / y >= z) {
                n -= y * z;
                x += 1;
            }
        }
        return x;
    }}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IGauge {
    function notifyRewardAmount(address token, uint amount) external;
    function getReward(address account, address[] memory tokens) external;
    function claimFees() external returns (uint claimed0, uint claimed1);
    function left(address token) external view returns (uint);
    function rewardRate(address _pair) external view returns (uint);
    function balanceOf(address _account) external view returns (uint);
    function isForPair() external view returns (bool);
    function totalSupply() external view returns (uint);
    function earned(address token, address account) external view returns (uint);
    
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IBribeFull {

    function _deposit(uint amount, uint tokenId) external;
    function _withdraw(uint amount, uint tokenId) external;
    function getRewardForOwner(uint tokenId, address[] memory tokens) external;
    function notifyRewardAmount(address token, uint amount) external;
    function left(address token) external view returns (uint);
    function rewardsListLength() external view returns (uint);
    function supplyNumCheckpoints() external view returns (uint);
    function getEpochStart(uint timestamp) external pure returns (uint);
    function getPriorSupplyIndex(uint timestamp) external view returns (uint);
    function rewards(uint index) external view returns (address);
    function tokenRewardsPerEpoch(address token,uint ts) external view returns (uint);
    function supplyCheckpoints(uint _index) external view returns(uint timestamp, uint supplyd);
    function earned(address token, uint tokenId) external view returns (uint);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IGaugeFactory {
    function createGauge(address, address, address, address, bool, address[] memory) external returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IWrappedBribeFactory {
    
    function voter() external view returns(address);
    function createBribe(address existing_bribe) external returns (address);
    function oldBribeToNew(address _external_bribe_addr) external view returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function balanceOf(address) external view returns (uint);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IMinter {
    function update_period() external returns (uint);
    function check() external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IPair {
    function metadata() external view returns (uint dec0, uint dec1, uint r0, uint r1, bool st, address t0, address t1);
    function claimFees() external returns (uint, uint);
    function tokens() external view returns (address, address);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function burn(address to) external returns (uint amount0, uint amount1);
    function mint(address to) external returns (uint liquidity);
    function getReserves() external view returns (uint _reserve0, uint _reserve1, uint _blockTimestampLast);
    function getAmountOut(uint, address) external view returns (uint);

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function totalSupply() external view returns (uint);
    function decimals() external view returns (uint8);

    function claimable0(address _user) external view returns (uint);
    function claimable1(address _user) external view returns (uint);

    function isStable() external view returns(bool);


    /*function token0() external view returns(address);
    function reserve0() external view returns(address);
    function decimals0() external view returns(address);
    function token1() external view returns(address);
    function reserve1() external view returns(address);
    function decimals1() external view returns(address);*/


}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IVoter {
    function _ve() external view returns (address);
    function governor() external view returns (address);
    function gauges(address _pair) external view returns (address);
    function factory() external view returns (address);
    function emergencyCouncil() external view returns (address);
    function attachTokenToGauge(uint _tokenId, address account) external;
    function detachTokenFromGauge(uint _tokenId, address account) external;
    function emitDeposit(uint _tokenId, address account, uint amount) external;
    function emitWithdraw(uint _tokenId, address account, uint amount) external;
    function isWhitelisted(address token) external view returns (bool);
    function notifyRewardAmount(uint amount) external;
    function distribute(address _gauge) external;
    function distributeAll() external;
    function distributeFees(address[] memory _gauges) external;

    function internal_bribes(address _gauge) external view returns (address);
    function external_bribes(address _gauge) external view returns (address);

    function usedWeights(uint id) external view returns(uint);
    function lastVoted(uint id) external view returns(uint);
    function poolVote(uint id, uint _index) external view returns(address _pair);
    function votes(uint id, address _pool) external view returns(uint votes);
    function poolVoteLength(uint tokenId) external view returns(uint);
    
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IPairFactory {
    function allPairsLength() external view returns (uint);
    function isPair(address pair) external view returns (bool);
    function allPairs(uint index) external view returns (address);
    function pairCodeHash() external pure returns (bytes32);
    function getPair(address tokenA, address token, bool stable) external view returns (address);
    function createPair(address tokenA, address tokenB, bool stable) external returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IVotingEscrow {

    struct Point {
        int128 bias;
        int128 slope; // # -dweight / dt
        uint256 ts;
        uint256 blk; // block
    }

    struct LockedBalance {
        int128 amount;
        uint end;
    }

    function create_lock_for(uint _value, uint _lock_duration, address _to) external returns (uint);

    function locked(uint id) external view returns(LockedBalance memory);
    function tokenOfOwnerByIndex(address _owner, uint _tokenIndex) external view returns (uint);

    function token() external view returns (address);
    function team() external returns (address);
    function epoch() external view returns (uint);
    function point_history(uint loc) external view returns (Point memory);
    function user_point_history(uint tokenId, uint loc) external view returns (Point memory);
    function user_point_epoch(uint tokenId) external view returns (uint);

    function ownerOf(uint) external view returns (address);
    function isApprovedOrOwner(address, uint) external view returns (bool);
    function transferFrom(address, address, uint) external;

    function voted(uint) external view returns (bool);
    function attachments(uint) external view returns (uint);
    function voting(uint tokenId) external;
    function abstain(uint tokenId) external;
    function attach(uint tokenId) external;
    function detach(uint tokenId) external;

    function checkpoint() external;
    function deposit_for(uint tokenId, uint value) external;

    function balanceOfNFT(uint _id) external view returns (uint);
    function balanceOf(address _owner) external view returns (uint);
    function totalSupply() external view returns (uint);
    function supply() external view returns (uint);


    function decimals() external view returns(uint8);
}