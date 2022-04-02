/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

pragma solidity 0.8.10;

// SPDX-License-Identifier:MIT
interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract DecentMenuScript {
    address public owner;
    IBEP20 public token;

  //  mapping(address => uint256 )public upVotes;

    uint256 public rewardToken = 50000 * 1e9;

    bool public isEnabled;


    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    constructor (address _owner, address _token){
        owner = _owner;
        token = IBEP20(_token);
    }
     
    function claimReward()public{ 
      //  require(isEnabled, "claim disabled");
        token.transferFrom(owner,msg.sender, rewardToken); 
    } 

    function changeReward(uint256 _amount) public onlyOwner{
        rewardToken = _amount;
    }

    function setRewardState(bool _state) public onlyOwner {
        isEnabled = _state;
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function changeToken(address newToken) public onlyOwner {
        token = IBEP20(newToken);
    }

}