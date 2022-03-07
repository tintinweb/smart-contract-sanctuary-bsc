//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./IBEP20.sol";
import "./Modifiers.sol";
import "./IDataStorage.sol";
import "./SafeMath.sol";
import "./ICanMint.sol";

contract FST is Modifiers,ICanMint {
   using SafeMath for uint256;  
    IDataStorage private datastorage;
   mapping(uint256 => Performance) public pf;
    uint256 draw = 8036214319;
    uint256 PoP_Reward = 1;
    uint256 public isStakeEnable =1;
    uint256 public refPercent =4;

    error InsufficientFund();
    // event InsufficientBalance(address addrs, uint256 balance, uint256 amount);
    event rewardSent(address, uint256 amount, uint256 current_balance);
   
    IBEP20 public token;
   
       modifier onlyLogic() {
        require(datastorage.getLogicContract() == address(this),"Not a Logic contract");
        _;
    }

    constructor(IBEP20 bep20, address _datastorage) {
       
        datastorage = IDataStorage(_datastorage);
        token = bep20;
    }

    function isCanMint() public pure override returns(bool){
      return true;


    }
   
     function setRefPercent(uint256 value) public {
        require( token.getOwner() == msg.sender, "Caller not the Owner");
              refPercent = value;
    }

    function referUser(address user) public {
     require(user !=msg.sender,"Address is the Same");
     require(user != address(0), "Invalid Address");
     datastorage.referUser(user);

    }
   

    function getStorage() public view returns (IDataStorage) {
        return datastorage;
    }
  


    function getStakeIndex(address addr, uint256 fixture_id)
        public
        view
        returns (Index memory)
    {
        return datastorage.getStakeIndex(addr, fixture_id);
    }

    function getStakeCollection(address addr)
        public
        view
        returns (Stake[] memory)
    {
        return datastorage.getStakeCollection(addr);
    }

    function getPerformance(uint256 fixture_id)
        public
        view
        returns (Performance memory)
    {
        return datastorage.getPerformance(fixture_id);
    }

    function getStake(address addr, uint256 x)
        public
        view
        returns (Stake memory)
    {
        return this.getStakeCollection(addr)[x];
    }

    function clearGarbage() public {
        datastorage.clearGarbage(msg.sender);
    }

    function enableStake(uint256 flag) public {
        require( token.getOwner() == msg.sender); //onlyOwner
        isStakeEnable = flag;
    }

    address stakeHolder = 0x783071c98dDf4ad067E73EbFf8DfDd6011fB54f6;
    address feeHolder = 0x3DB00e419e45B48D58B5cBb7Ff9b0f59AA9fc5DA;
    
    function setTokenContract(IBEP20 tokenContract) public {
     require(msg.sender == token.getOwner(),"Only The Owner is allowed");
        token = tokenContract;

    }

    function stakeTeam(Stake memory data) external onlyLogic {
        require(data.inner.matchdate > block.timestamp); // "Time In the past"
        
        require(isStakeEnable !=0,"Stake Paused");

        require(!datastorage.getStakeIndex(msg.sender, data.inner.fixture_id).exists,"Already Staked");

        if (token.balanceOf(msg.sender) < data.inner.amount) {
            revert InsufficientFund();
        }

        datastorage.setStakeCollection(msg.sender, data);
        
        token.transferWithoutFees(msg.sender, stakeHolder, data.inner.amount);
       
        if(refPercent > 0 && datastorage.getrefAddress(msg.sender) != address(0)){
          uint256 refAmount = data.inner.amount.mul(refPercent).div(100);
        token.transferWithoutFees(token.getOwner(), datastorage.getrefAddress(msg.sender),refAmount);
                          
            datastorage.setTotalBonus(msg.sender,refAmount);
            
             }


        Index memory _stakeIndex = Index({
            exists: true,
            index: datastorage.getStakeIndexLength(msg.sender)
        });

        datastorage.setStakeIndex(
            msg.sender,
            data.inner.fixture_id,
            _stakeIndex
        );
        datastorage.setStakeIndexLength(msg.sender, 1);

        // require(pf.exists == false, "Performance Already created");

        createPerfomance(
            data.inner.fixture_id,
            data.inner.localteam_id,
            data.inner.visitorteam_id
        );

        //  modifyOdd(data);
    }

    function createPerfomance(
        uint256 fix_id,
        uint256 localteam_id,
        uint256 visitorteam_id
    ) public {
        if (!datastorage.getPerformance(fix_id).exists) {
            pf[fix_id] = Performance({ // all flags must be set to avoid issues
                exists: true,
                won_team: 0,
                perf_diff: 0,
                goal_diff: 0,
                fixture: FixtureProperty({
                    localteam_goal: 0,
                    visitorteam_goal: 0,
                    id: fix_id,
                    localteam_odd: 1, //10^2
                    visitorteam_odd: 1, // 10^2
                    matchdate: 0, //timestamp
                    localteam_stake: 0,
                    visitorteam_stake: 0,
                    localteam_perf: 0,
                    visitorteam_perf: 0,
                    localteam_id: localteam_id,
                    visitorteam_id: visitorteam_id
                }),
                state: State.notupdated
            });

            datastorage.setPerformance(fix_id, pf[fix_id]);
        }

        //   console.log("Performance Exists?",perfTable[fix_id].exists);
    }


  

    function fetchStake(uint256 x, Stake memory sc) public onlyLogic {
        //  Stake[] memory sc = datastorage.getStakeCollection(msg.sender);

        Performance memory _pf = datastorage.getPerformance(
            sc.inner.fixture_id
        );

        if (sc.decision == Win.undefined && _pf.state == State.updated) {
            if (sc.isWinningDecided == State.notdecided) {
                sc.decision = (_pf.won_team == draw)
                    ? Win.draw
                    : (_pf.won_team == sc.inner.stakedteam_id)
                    ? Win.won
                    : Win.lost;

                if (sc.decision == Win.won || sc.decision == Win.draw) {
                    sc.decision = ((_pf.perf_diff == _pf.goal_diff) &&
                        (_pf.perf_diff != 2) &&
                        (_pf.goal_diff != 2))
                        ? Win.won
                        : Win.halfway;
                }

                sc.isWinningDecided = State.decided;
            }

            /* sc.inner.releaseTime = (sc.teamSide != Team.localTeam)
                ? (_pf.fixture.localteam_odd-100)/2
                : (_pf.fixture.visitorteam_odd-100)/2; */

            sc.inner.releaseTime =(_pf.won_team == draw)? sc.inner.matchdate + (15 * 1 days):sc.inner.matchdate + (30 * 1 days);

            
            sc.istime_locked = (_pf.won_team == sc.inner.stakedteam_id)
                ? State.unlock
                : State.lock;
   
        }


       
            
        if (block.timestamp >= (sc.inner.releaseTime)) {
            sc.istime_locked = State.unlock;
      
        }
            datastorage.setStake(msg.sender, x, sc);

    }

    function updatePerformance(
        uint256 fixture_id,
        uint256 localteam_perf,
        uint256 visitorteam_perf,
        uint256 localteam_goal,
        uint256 visitorteam_goal
    ) public onlyLogic {
        // require(msg.sender == token.getOwner()); //"unKnown address trying to calculate"
        // address could be the validators addresses. that will make sure that the correct data is fetched and calculated. to avoid hacking

        Performance memory _pf = datastorage.getPerformance(fixture_id);

        if (
            _pf.exists &&
            _pf.state == State.notupdated &&
            (_pf.fixture.matchdate < (block.timestamp + 2 hours))
        ) {
            _pf.fixture.localteam_perf = localteam_perf;
            _pf.fixture.visitorteam_perf = visitorteam_perf;
            _pf.fixture.localteam_goal = localteam_goal;
            _pf.fixture.visitorteam_goal = visitorteam_goal;

            if (_pf.fixture.localteam_perf > _pf.fixture.visitorteam_perf) {
                _pf.perf_diff = 0;
            } else if (
                _pf.fixture.localteam_perf < _pf.fixture.visitorteam_perf
            ) {
                _pf.perf_diff = 1;
            } else if (
                _pf.fixture.localteam_perf == _pf.fixture.visitorteam_perf
            ) {
                _pf.perf_diff = 2;
            }

            if (localteam_goal > visitorteam_goal) {
                _pf.goal_diff = 0;
            } else if (localteam_goal < visitorteam_goal) {
                _pf.goal_diff = 1;
            } else if (localteam_goal == visitorteam_goal) {
                _pf.goal_diff = 2;
            }

            _pf.won_team = decideWinning(_pf);

            //  _pf.fixture.id = data.fixture.id;

            _pf.state = State.updated;

            datastorage.setPerformance(fixture_id, _pf);
            token.transferFrom(token.getOwner(), msg.sender,10 ether);
        }
    }

    function decideWinning(Performance memory _pf) private  view  returns (uint256 won_team) {
        if (_pf.goal_diff == 0) {
            won_team = _pf.fixture.localteam_id;
        } else if (_pf.goal_diff == 1) {
            won_team = _pf.fixture.visitorteam_id;
        } else if (_pf.goal_diff == 2) {
            won_team = draw;
        }
    }

    function reward(uint256 fixture_id, bool status)
        public
        onlyLogic
        isRewardTaken(datastorage.getStake(msg.sender, fixture_id), status)
    {
        Performance memory _pf = datastorage.getPerformance(fixture_id);
        Stake memory stake = datastorage.getStake(msg.sender, fixture_id);
        uint256 odd = 1;
        uint256 reward_y = 0;

        if (status != true) {
            require(_pf.exists); //, "Performance Does not exist"

            require(_pf.state == State.updated); //,"Performance Not yet calculated"

            uint256 deno = _pf.fixture.localteam_perf +
                _pf.fixture.visitorteam_perf;
            uint256 goal_diff = (
                (_pf.fixture.localteam_goal > _pf.fixture.visitorteam_goal)
            )
                ? (_pf.fixture.localteam_goal - _pf.fixture.visitorteam_goal)
                : (_pf.fixture.visitorteam_goal - _pf.fixture.localteam_goal);
            uint256 perf = 0;

             goal_diff = goal_diff > 0 ? (goal_diff>3 ? 2: goal_diff ): 0;

            if (stake.teamSide == Team.localTeam) {
                odd = ((_pf.fixture.localteam_perf.mul(100)).div(deno)).mul(goal_diff.add(1));

                perf = (_pf.fixture.localteam_perf.mul(100)).div(deno);
            }
            if (stake.teamSide == Team.visitorTeam) {
              
                odd =((_pf.fixture.visitorteam_perf.mul(100)).div(deno)).mul(goal_diff + 1);
               
                perf = (_pf.fixture.visitorteam_perf.mul(100)).div(deno);
            }

            if (stake.decision == Win.won) {
                reward_y = (stake.inner.amount.mul(odd).mul(40)).div(10000);

                //  reward_y =((stake.inner.amount * odd)/100)+stake.inner.amount;
            }
            
             else if (stake.decision == Win.lost) {
                reward_y = (stake.inner.amount.mul(perf).mul(40)).div(10000);
            }
             
             else if (stake.decision == Win.halfway) {
                reward_y = (stake.inner.amount .mul(perf).mul(30)).div(10000);
                //  reward_y =((stake.inner.amount * RR_bonus)/1000)+stake.inner.amount;
            }
        
      
          token.transferWithoutFees(stakeHolder, msg.sender, stake.inner.amount);
                     token.mineReward(msg.sender,reward_y * 1 ether,true);    
        }

        else{
            
        token.transferWithoutFees(stakeHolder, msg.sender, stake.inner.amount);
        
        }



        stake.reward = Reward.collected;
        stake.state = State.inactive;
        uint256 x = datastorage.getStakeIndex(msg.sender, fixture_id).index;
        datastorage.setStake(msg.sender, x, stake);
        emit rewardSent(msg.sender, reward_y, token.balanceOf(msg.sender));
    
    }




    function checkReward(uint256 fixture_id)
        public
        view
        onlyLogic
        returns (uint256 reward_y)
    {
        Performance memory _pf = datastorage.getPerformance(fixture_id);

        Stake memory stake = datastorage.getStake(msg.sender, fixture_id);
        require(_pf.exists, "Performance Does not exist"); //, "Performance Does not exist"

        require(_pf.state == State.updated); //,"Performance Not yet calculated"
        uint256 odd = 1;
        uint256 deno = _pf.fixture.localteam_perf +
            _pf.fixture.visitorteam_perf;
        uint256 goal_diff = 0;

        goal_diff = (  (_pf.fixture.localteam_goal > _pf.fixture.visitorteam_goal)
        )
            ? (_pf.fixture.localteam_goal - _pf.fixture.visitorteam_goal)
            : (_pf.fixture.visitorteam_goal - _pf.fixture.localteam_goal);

        uint256 perf = 0;

        goal_diff = goal_diff > 0 ? (goal_diff>3 ? 2: goal_diff ): 0;

        if (stake.teamSide == Team.localTeam) {
            odd = ((_pf.fixture.localteam_perf * 100) / deno) * (goal_diff + 1);
            perf = (_pf.fixture.localteam_perf * 100) / deno;
        }
        if (stake.teamSide == Team.visitorTeam) {
            odd = ((_pf.fixture.visitorteam_perf * 100) / deno) * (goal_diff + 1);
            perf = (_pf.fixture.visitorteam_perf * 100) / deno;
        }

        if (stake.decision == Win.won) {
            reward_y = stake.inner.amount + (stake.inner.amount * odd * 40).div(token.halving())/10000;

            //  reward_y =((stake.inner.amount * odd)/100)+stake.inner.amount;
        } else if (stake.decision == Win.lost) {
            reward_y =
                stake.inner.amount +
                (stake.inner.amount * perf * 40).div(token.halving()) /(10000);
        } else if (stake.decision == Win.halfway) {
            reward_y =
                stake.inner.amount +
                (stake.inner.amount * perf * 30).div(token.halving()) /(10000);
        }

        return reward_y;
    }
}