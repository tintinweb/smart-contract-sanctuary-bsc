// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IInvite {
    function addinvite(address) external returns(bool);
    function getParents(address) external view returns(address[1] memory);
    function getChilds(address) external view returns(address[] memory);
    function getInviteNum(address) external view returns(uint256[6] memory);
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Bind is IInvite {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public factory;
    mapping(address => address[]) public inviteRecords;
    mapping(address => address) public parents;
    mapping(address => uint256[6]) public inviteNumRecords;
    address public firstAddress;
    uint256 public totalPeople;
 
    constructor() {
        factory = msg.sender;
        firstAddress = 0x8354869Cb3E497441807d28c60bd99a2FcDc42e4;
    }

    function claimToken(address token, uint256 amount, address to) external virtual returns(bool){
        require(msg.sender == factory, 'Invite: 0008');
        IERC20(token).transfer(to, amount);
        return true;
    }

 
    function addinvite(address parentAddress) external override returns(bool){
        require(parentAddress != address(0), 'Invite: 0001');
        address myAddress = msg.sender;
        require(parentAddress != myAddress, 'Invite: 0002');
        require(parents[parentAddress] != address(0) || parentAddress == firstAddress, 'Invite: 0003');
        if(parents[myAddress] != address(0)){
            return true;
        }
        inviteRecords[parentAddress].push(myAddress);
        parents[myAddress] = parentAddress;
        inviteNumRecords[parentAddress][0]++;
        inviteNumRecords[parents[parentAddress]][1]++;
        inviteNumRecords[parents[parents[parentAddress]]][2]++;
        inviteNumRecords[parents[parents[parents[parentAddress]]]][3]++;
        inviteNumRecords[parents[parents[parents[parents[parentAddress]]]]][4]++;
        inviteNumRecords[parents[parents[parents[parents[parents[parentAddress]]]]]][5]++;
        totalPeople++;
        return true;
    }

    function getParents(address myAddress) external view override returns(address[1] memory myParents){
        address firstParent = parents[myAddress];
        myParents = [firstParent];
    }
 
    function getChilds(address myAddress) external view override returns(address[] memory childs){
        childs = inviteRecords[myAddress];
    }
 
    function getInviteNum(address myAddress) external view override returns(uint256[6] memory){
        return inviteNumRecords[myAddress];
    }
 
    function setFirstAddress(address _firstAddress) external virtual returns(bool){
        require(msg.sender == factory, 'Invite: 0009');
        firstAddress = _firstAddress;
        return true;
    }
}