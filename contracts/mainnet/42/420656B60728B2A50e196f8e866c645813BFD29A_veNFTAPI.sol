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
import '../interfaces/IRewardsDistributor.sol';


interface IPairAPI {
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

    function getPair(address _pair, address _account) external view returns(pairInfo memory _pairInfo);

    function pair_factory() external view returns(address);
}

contract veNFTAPI {

    struct pairVotes {
        address pair;
        uint256 weight;
    }

    struct veNFT {
        uint8 decimals;
        
        bool voted;
        uint256 attachments;

        uint256 id;
        uint128 amount;
        uint256 voting_amount;
        uint256 rebase_amount;
        uint256 lockEnd;
        uint256 vote_ts;
        pairVotes[] votes;        
        
        address account;

        address token;
        string tokenSymbol;
        uint256 tokenDecimals;
    }

    struct Reward {
        
        uint256 id;
        uint256 amount;  
        uint8 decimals;
        
        address pair;
        address token;
        address fee;
        address bribe;

        string symbol;
    }


    
    uint256 constant public MAX_RESULTS = 1000;
    uint256 constant public MAX_PAIRS = 30;

    IVoter public voter;
    address public underlyingToken;

    IVotingEscrow public ve;
    IRewardsDistributor public rewardDisitributor;

    address public pairAPI;
    IPairFactory public pairFactory;
    

    address public owner;
    event Owner(address oldOwner, address newOwner);


    constructor(address _voter, address _rewarddistro, address _pairApi, address _pairFactory) {
        owner = msg.sender;

        pairAPI = _pairApi;
        voter = IVoter(_voter);
        rewardDisitributor = IRewardsDistributor(_rewarddistro);

        require(rewardDisitributor.voting_escrow() == voter._ve(), 've!=ve');
        
        ve = IVotingEscrow( rewardDisitributor.voting_escrow() );
        underlyingToken = IVotingEscrow(ve).token();

        pairFactory = IPairFactory( _pairFactory );

    }


    function getAllNFT(uint256 _amounts, uint256 _offset) external view returns(veNFT[] memory _veNFT){

        require(_amounts <= MAX_RESULTS, 'too many nfts');
        _veNFT = new veNFT[](_amounts);

        uint i = _offset;
        address _owner;

        for(i; i < _offset + _amounts; i++){
            _owner = ve.ownerOf(i);
            // if id_i has owner read data
            if(_owner != address(0)){
                _veNFT[i-_offset] = _getNFTFromId(i, _owner);
            }
        }
    }

    function getNFTFrom(uint256 id) external view returns(veNFT memory){
        return _getNFTFromId(id,ve.ownerOf(id));
    }

    function getNFTFrom(address _user) external view returns(veNFT[] memory venft){

        uint256 i=0;
        uint256 _id;
        uint256 totNFTs = ve.balanceOf(_user);

        venft = new veNFT[](totNFTs);

        for(i; i < totNFTs; i++){
            _id = ve.tokenOfOwnerByIndex(_user, i);
            if(_id != 0){
                venft[i] = _getNFTFromId(_id, _user);
            }
        }
    }

    function _getNFTFromId(uint256 id, address _owner) internal view returns(veNFT memory venft){

        if(_owner == address(0)){
            return venft;
        }

        uint _totalPoolVotes = voter.poolVoteLength(id);
        pairVotes[] memory votes = new pairVotes[](_totalPoolVotes);

        IVotingEscrow.LockedBalance memory _lockedBalance;
        _lockedBalance = ve.locked(id);

        uint k;
        uint256 _poolWeight;
        address _votedPair;

        for(k = 0; k < _totalPoolVotes; k++){

            _votedPair = voter.poolVote(id, k);
            if(_votedPair == address(0)){
                break;
            }
            _poolWeight = voter.votes(id, _votedPair);
            votes[k].pair = _votedPair;
            votes[k].weight = _poolWeight;
        }

        venft.id = id;
        venft.account = _owner;
        venft.decimals = ve.decimals();
        venft.amount = uint128(_lockedBalance.amount);
        venft.voting_amount = ve.balanceOfNFT(id);
        venft.rebase_amount = rewardDisitributor.claimable(id);
        venft.lockEnd = _lockedBalance.end;
        venft.vote_ts = voter.lastVoted(id);
        venft.votes = votes;
        venft.token = ve.token();
        venft.tokenSymbol =  IERC20( ve.token() ).symbol();
        venft.tokenDecimals = IERC20( ve.token() ).decimals();
        venft.voted = ve.voted(id);
        venft.attachments = ve.attachments(id);
      
    }

    
    function allPairRewards(uint256 _amount, uint256 _offset, uint256 id) external view returns(Reward[] memory rewards){
        
        rewards = new Reward[](MAX_RESULTS);

        uint256 totalPairs = pairFactory.allPairsLength();
        
        uint i = _offset;
        address _pair;
        for(i; i < _offset + _amount; i++){
            if(i >= totalPairs){
                break;
            }
            _pair = pairFactory.allPairs(i);
            rewards = _pairReward(_pair, id);
        }
    }

    function singlePairReward(uint256 id, address _pair) external view returns(Reward[] memory _reward){
        return _pairReward(_pair, id);
    }


    function _pairReward(address _pair, uint256 id) internal view returns(Reward[] memory _reward){

        IPairAPI.pairInfo memory _pairApi = IPairAPI(pairAPI).getPair(_pair, address(0));

        address wrappedBribe = _pairApi.wrapped_bribe;
        uint256 totBribeTokens = IBribeFull(wrappedBribe).rewardsListLength();
        uint bribeAmount;

        if(_pair == address(0)){
            //return;
        }
        address _gauge = (voter.gauges(_pair));
        if(_gauge == address(0)){
            //return; 
        }

        (,,,,, address t0, address t1) = IPair(_pair).metadata();
        uint256 _feeToken0 = IBribeFull(_pair).earned(t0, id);
        uint256 _feeToken1 = IBribeFull(_pair).earned(t1, id);

        _reward = new Reward[](2 + bribeAmount);

        if(_feeToken0 > 0){
            _reward[0] = Reward({
                id: id,
                pair: _pair,
                amount: _feeToken0,
                token: t0,
                symbol: IERC20(t0).symbol(),
                decimals: IERC20(t0).decimals(),
                fee: voter.internal_bribes(address(_gauge)),
                bribe: address(0)
            });
        }

        if(_feeToken1 > 0){
            _reward[1] = Reward({
                id: id,
                pair: _pair,
                amount: _feeToken1,
                token: t1,
                symbol: IERC20(t1).symbol(),
                decimals: IERC20(t1).decimals(),
                fee: voter.internal_bribes(address(_gauge)),
                bribe: address(0)
            });
        }

        if(wrappedBribe == address(0)){
            return _reward;
        }

        uint k = 0;
        address _token;
        for(k; k < totBribeTokens; k++){
            _token = IBribeFull(wrappedBribe).rewards(k);
            bribeAmount = IBribeFull(wrappedBribe).earned(_token, id);
            _reward[2 + k] = Reward({
                id: id,
                pair: _pair,
                amount: bribeAmount,
                token: _token,
                symbol: IERC20(_token).symbol(),
                decimals: IERC20(_token).decimals(),
                fee: address(0),
                bribe: wrappedBribe
            });
        }   

        return _reward;
    }
    



    function setOwner(address _owner) external {
        require(msg.sender == owner, 'not owner');
        require(_owner != address(0), 'zeroAddr');
        owner = _owner;
        emit Owner(msg.sender, _owner);
    }



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

interface IWrappedBribeFactory {
    
    function voter() external view returns(address);
    function createBribe(address existing_bribe) external returns (address);
    function oldBribeToNew(address _external_bribe_addr) external view returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IMinter {
    function update_period() external returns (uint);
    function check() external view returns(bool);
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

interface IGaugeFactory {
    function createGauge(address, address, address, address, bool, address[] memory) external returns (address);
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

interface IRewardsDistributor {
    function checkpoint_token() external;
    function voting_escrow() external view returns(address);
    function checkpoint_total_supply() external;
    function claimable(uint _tokenId) external view returns (uint);
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