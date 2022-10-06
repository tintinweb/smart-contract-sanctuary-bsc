// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./BugKiller.sol";



interface IBugKiller {
    function balanceBug(address _user) external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _user) external view returns(uint256);
}

contract BugCoin is ERC20, ERC20Burnable,ReentrancyGuard, Ownable {
    uint256 public END = 2272165200;
    uint256 public MINT_BONUS = 1000 ether;
    uint256 public teamFee = 5;
    uint256 public rewardAmount = 1 ether;
    uint256 public mintAmount = 2;

    address public teamAddress = 0x3d9865f8e5b702220A43b81F1D05580e6F7A8327;

    mapping(address => bool) councillors;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastUpdate;

    IBugKiller public bugKiller;

    event CouncillorAdded(address councillor);
    event CouncillorRemoved(address councillor);
    event RewardPaid(address indexed user, uint256 reward);

    constructor() ERC20("BugCoin", "BugCoin") {
    }

    function setBugKiller(address _address) external onlyOwner {
        bugKiller = IBugKiller(_address);
        addCouncillor(_address);
    }

    function setEnd(uint256 time) external onlyOwner {
        END = time;
    }

    function setRewardAmount(uint256 amount) external onlyOwner {
        rewardAmount = amount;
    }

    function setMintBouns(uint256 amount) external onlyOwner {
        MINT_BONUS = amount;
    }


    function setTeamFee(uint256 _teamFee) external onlyOwner {
        teamFee = _teamFee;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function isCouncillor(address _councillor) public view returns(bool) {
        return councillors[_councillor];
    }

    function addCouncillor(address _councillor) public onlyOwner {
       require(_councillor != address(0), "Cannot add null address");
       councillors[_councillor] = true;
       emit CouncillorAdded(_councillor);
    }

    function removeCouncillor(address _councillor) public onlyOwner {
        require(isCouncillor(_councillor), "Not a councillor");
        delete councillors[_councillor];
        emit CouncillorRemoved(_councillor);
    }

        // updated_amount = (balanceAngel(user) * rewardAmount * delta / 86400) + amount * initial rate
    function updateRewardOnMint(address _user, uint256 _amount) external {
        require(councillors[msg.sender], "Unauthorized");

        uint256 time = min(block.timestamp, END);
        uint256 timerUser = lastUpdate[_user];
        uint256 timerRemainder = 0;
        uint256 balanceBug = bugKiller.balanceBug(_user);

        if(balanceBug >= mintAmount){
            balanceBug = mintAmount;
        }

        //update reward count is this is not their first mint
        if (timerUser > 0) {
            rewards[_user] = rewards[_user] + (balanceBug * rewardAmount * ((time - timerUser) / 86400));
            timerRemainder = (time - timerUser) % 86400;
        }

        //award 0 LBT per nft
        rewards[_user] += MINT_BONUS * _amount;
        
        //set new last updated
        lastUpdate[_user] = time - timerRemainder;
    }


    // updated_amount = (balanceBug(user) * rewardAmount * delta / 86400) + amount * initial rate
    function updateBounsOnMint(address _user, uint256 _amount) external {
        require(councillors[msg.sender], "Unauthorized");

        uint256 balanceBug = bugKiller.balanceBug(_user);

        if(balanceBug >= mintAmount){
            balanceBug = mintAmount;
        }

        //award 0 coin per nft
        rewards[_user] += MINT_BONUS * _amount;
    }

    // called on transfers
    function updateReward(address _from, address _to, uint256 _tokenId) external {
        require(councillors[msg.sender], "Unauthorized");
        require(_tokenId <= totalSupply() , "Max supply reached");
        
        uint256 time = min(block.timestamp, END);
        uint256 timerFrom = lastUpdate[_from];
        uint256 timerRemainderFrom = 0;
        uint256 fromBalanceBug = bugKiller.balanceBug(_from);
        uint256 toBalanceBug = bugKiller.balanceBug(_to);

            if(fromBalanceBug >= mintAmount){
            fromBalanceBug = mintAmount;
            }

            if(toBalanceBug >= mintAmount){
            toBalanceBug = mintAmount;
            }

            if (timerFrom > 0) {
                rewards[_from] +=  fromBalanceBug * rewardAmount * ((time - timerFrom) / 86400);
                timerRemainderFrom = (time - timerFrom) % 86400;
            }

            if (timerFrom != END) {
                lastUpdate[_from] = time - timerRemainderFrom;
            }

            if (_to != address(0)) {
                uint256 timerTo = lastUpdate[_to];
                uint256 timerRemainderTo = 0;

            if (timerTo > 0) {
                rewards[_to] +=   toBalanceBug * rewardAmount * ((time - timerTo) / 86400);
                timerRemainderTo = (time - timerTo) % 86400;
                }

                if (timerTo != END) {
                    lastUpdate[_to] = time - timerRemainderTo;
                }
            }
        
    }

    function getReward(address _to) external nonReentrant{
        require(councillors[msg.sender], "Unauthorized");
        
        uint256 reward = rewards[_to];
        if (reward > 0) {
            rewards[_to] = 0;            
            _mint(_to, reward);
            emit RewardPaid(_to, reward);
        }
    }

    function mint(address to, uint256 amount) external nonReentrant{
        require(councillors[msg.sender], "Unauthorized");
        _mint(to, amount);
    }

    function burn(address _from, uint256 _amount) external nonReentrant{
        require(councillors[msg.sender], "Unauthorized");
        
        _burn(_from, _amount);
    }

  function burnFrom(address account, uint256 amount) public override {
      if (councillors[msg.sender]) {
          _burn(account, amount);
      }
      else {
          super.burnFrom(account, amount);
      }
  }

    function transferFeeFrom(address from, address to, uint256 amount) public{
      if (councillors[msg.sender]) {
          _transfer(from,to, amount);
      }
  }

    function getTotalClaimable(address _user) external view returns(uint256) {
        uint256 time = min(block.timestamp, END);
        uint256 balanceBug = bugKiller.balanceBug(_user);

        if(balanceBug >= mintAmount){
            balanceBug = mintAmount;
        }

        uint256 pending = balanceBug* rewardAmount * ((time - lastUpdate[_user]) / 86400);
        return rewards[_user] + pending;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);

        payable(msg.sender).transfer(balance);
    }

  function withdrawAllERC20(address _tokenContract, uint256 _amount) public onlyOwner {
    require(_amount > 0);
    IERC20 tokenContract = IERC20(_tokenContract);
    require(tokenContract.balanceOf(address(this)) >= _amount, 'Contract does not own enough tokens');
    tokenContract.transfer(msg.sender, _amount );
  }
}