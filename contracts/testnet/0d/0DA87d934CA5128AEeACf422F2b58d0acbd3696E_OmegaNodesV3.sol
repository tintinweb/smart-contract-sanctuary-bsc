/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

// ----------------------------------------------------------------------------
// --- Name   : OmegaNodes - [https://om.paideia.global/]
// --- Symbol : Format - {OM}
// --- Supply : Generated from share of each pool 
// --- @title : the Beginning and the End 
// --- 01000110 01101111 01110010 00100000 01110100 01101000 01100101 00100000 01101100 
// --- 01101111 01110110 01100101 00100000 01101111 01100110 00100000 01101101 01111001 
// --- 00100000 01100011 01101000 01101001 01101100 01100100 01110010 01100101 01101110
// --- Paideia.Global - EJS32 - 2021
// --- @dev pragma solidity version:0.8.10+commit.fc410830
// --- SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

pragma solidity >=0.4.22 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract Om is ERC20 {
}

abstract contract Ox is ERC20 {
}

// ----------------------------------------------------------------------------
// --- Contract OmegaNodes
// ----------------------------------------------------------------------------

contract OmegaNodesV3 {
  uint public totalNodes;
  address [] public accountAddresses; 
  Om public omAddress;
  Ox public oxAddress;
  address private owner;
  uint public accountNodeLimit = 100;

  struct Node {
    uint nodeType;
    uint createdAt;
  }

  struct Account {
    bool exists;
    bool archived;
    mapping(uint => Node) nodes;
    uint nodesLength;
    uint lastWithdrawalAt;
  }

  mapping(address => Account) public accounts;

  uint [] public nodeMultiplers = [
    1 * 10 ** 18,  // Iota Pool reward: 1 OM
    3 * 10 ** 18,  // Lambda Pool reward: 3 OM
    7 * 10 ** 18,  // Phi Pool reward: 7 OM
    16 * 10 ** 18, // Chilia reward: 16 OM
    100 * 10 ** 18 // Ekato Pool reward: 100 OM
  ];

  uint [] public requiredAmounts = [
    100  * 10 ** 18, // Iota Pool: 100 OX  - 100 OM
    250  * 10 ** 18, // Lambda Pool: 250 OX  - 250 OM
    500  * 10 ** 18, // Phi Pool: 500 OX  - 500 OM
    1000 * 10 ** 18, // Chilia: 1000 OX - 1000 OM
    5000 * 10 ** 18  // Ekato Pool: 5000 OX - 5000 OM
  ];

  uint [] public rotTargetForNodes = [
    8.64  * 10 ** 6,  // Iota Pool: 100 days in seconds
    7.258 * 10 ** 6,  // Lambda Pool:  84 days in seconds
    6.221 * 10 ** 6,  // Phi Pool:  72 days in seconds
    5.443 * 10 ** 6,  // Chilia:  63 days in seconds
    4.32  * 10 ** 6   // Ekato Pool:  50 days in seconds
  ];

  uint public cooldownTimeInSeconds = 1.21 * 10 ** 6;  // 14 days in seconds
  uint public percentageOfRewardBeforeCooldown  = 50;  // 50%
  uint public percentageOfRewardAfterCooldown   = 60;  // 60%

  constructor(Om _omAddress, Ox _oxAddress) {
    owner = msg.sender;
    omAddress = _omAddress;
    oxAddress = _oxAddress;
  }

  function migrateMultiple(address [] memory _addresses, uint [][] memory _nodeArgs) external {
    require(msg.sender == owner, 'Only the owner can run this.');

    for(uint i=0; i< _addresses.length; i++) {
      address a = _addresses[i];
      uint nodeType = _nodeArgs[i][0];
      uint nodeCreatedAt = _nodeArgs[i][1];

      if(!accounts[a].exists){
        accounts[a].exists = true;
        accounts[a].nodesLength = 0;
        accounts[a].lastWithdrawalAt = block.timestamp;
        accountAddresses.push(a);
      }

      accounts[a].nodes[accounts[a].nodesLength] = Node(nodeType, nodeCreatedAt);
      accounts[a].nodesLength++;
      totalNodes++;
    }
  }

  function setNodeMultipliers(uint _newRewards, uint _nodeType) external{
    require(msg.sender == owner, 'Only the owner can run this.');
    require(_newRewards > 0, "Reward can not be zero!");
    require(_nodeType >= 0 && _nodeType <= 7, "Node type not recognized");
    nodeMultiplers[_nodeType] = _newRewards;
  }

  function setRequiredAmounts(uint _newAmountRequired, uint _nodeType) external{
    require(msg.sender == owner, 'Only the owner can run this.');
    require(_newAmountRequired > 0, "Required amount can not be zero!");
    require(_nodeType >= 0 && _nodeType <= 7, "Node type not recognized");
    requiredAmounts[_nodeType] = _newAmountRequired;
  }

  function setRotTargetForNode(uint _newRotTarget, uint _nodeType) external{
    require(msg.sender == owner, 'Only the owner can run this.');
    require(_newRotTarget > 0, "ROT target can not be zero!");
    require(_nodeType >= 0 && _nodeType <= 7, "Node type not recognized");
    rotTargetForNodes[_nodeType] = _newRotTarget;
  }

  function setAccountNodeLimit(uint _nodeLimit) external {
    require(_nodeLimit > 0, "Node limit must be greater than 0");
    require(msg.sender == owner, 'Only the owner can run this.');
    accountNodeLimit = _nodeLimit;
  }

  function setCooldownTimeInSeconds(uint _cooldownTimeInSeconds) external {
    require(msg.sender == owner, 'Only the owner can run this.');
    cooldownTimeInSeconds = _cooldownTimeInSeconds;
  }

  function setPercentageOfRewardBeforeCooldown(uint _percentageOfRewardBeforeCooldown) external {
    require(msg.sender == owner, 'Only the owner can run this.');
    percentageOfRewardBeforeCooldown = _percentageOfRewardBeforeCooldown;
  }

  function setPercentageOfRewardAfterCooldown(uint _percentageOfRewardAfterCooldown) external {
    require(msg.sender == owner, 'Only the owner can run this.');
    percentageOfRewardAfterCooldown = _percentageOfRewardAfterCooldown;
  }

  function archiveAccount(address _address) external {
    require(_address != address(0), "_address is address 0");
    require(msg.sender == owner, 'Only the owner can run this.');
    Account storage account = accounts[_address];
    require(!account.archived, 'This account is already archived.');
    account.archived = true;
    totalNodes -= account.nodesLength;
  }

  function activateAccount(address _address) external {
    require(_address != address(0), "_address is address 0");
    require(msg.sender == owner, 'Only the owner can run this.');
    Account storage account = accounts[_address];
    require(account.archived, 'This account is already active.');
    account.archived = false;
    totalNodes += account.nodesLength;
  }

  function getTotalNodes() external view returns(uint) {
    return totalNodes;
  }

  function getAccountsLength() external view returns(uint) {
    return accountAddresses.length;
  }

  function getAccountsAddressForIndex(uint _index) external view returns(address) {
    return accountAddresses[_index];
  }

  function getAccount(address _address) external view returns(Node[] memory, uint, uint, bool) {
    Account storage data = accounts[_address];
    Node[] memory nodes = new Node[](data.nodesLength);
    for (uint i = 0; i < data.nodesLength; i++) {
      nodes[i] = data.nodes[i];
    }

    return(nodes, data.nodesLength, data.lastWithdrawalAt, data.archived);
  }

  function getNodesForAccount(address _address) external view returns(uint[][] memory) {
    Account storage data = accounts[_address];

    uint[][] memory nodesArr = new uint[][](data.nodesLength);
    for (uint i = 0; i < data.nodesLength; i++) {
      nodesArr[i] = new uint[](2);
      nodesArr[i][0] = data.nodes[i].nodeType;
      nodesArr[i][1] = data.nodes[i].createdAt;
    }

    return(nodesArr);
  }

  function mintNode(address _address, uint _omAmount, uint _oxAmount, uint _nodeType) external {
    require(_address != address(0), "_address is address 0");
    require(msg.sender == _address, 'Only this account can create a node.');
    require(_nodeType >= 0 && _nodeType <= 4, 'Invalid node type'); //their are 5 nodes
    // require(_nodeType >= 0 && _nodeType <= 7, 'Invalid node type'); //their are 5 nodes here its handling 8
    require(_omAmount == requiredAmounts[_nodeType], 'You must provide the corrent amount of OM');
    require(_oxAmount == requiredAmounts[_nodeType], 'You must provide the corrent amount of OX');

    Account storage account;

    if(accounts[_address].exists){
      account = accounts[_address];
    }
    else{
      accounts[_address].exists = true;
      accounts[_address].nodesLength = 0;
      accounts[_address].lastWithdrawalAt = block.timestamp;
      accountAddresses.push(_address);
      account = accounts[_address];
    }

    require(!account.archived, 'This account is blacklisted.');
    require(account.nodesLength < accountNodeLimit, 'Maximum node limit reached!');

    account.nodes[account.nodesLength] = Node(_nodeType, block.timestamp);
    account.nodesLength++;
    totalNodes++;

    omAddress.transferFrom(_address, address(this), _omAmount);
    oxAddress.transferFrom(_address, address(this), _oxAmount);
  }

  function isWithdrawalAvailable(address _to, uint _timestamp) external view returns(bool){
    require(_to != address(0), "_to is address 0");
    require(msg.sender == _to, 'Only this user can see their own funds.');
    Account storage account = accounts[_to];
    require(!account.archived, 'This account is blacklisted.');
    return ((_timestamp - account.lastWithdrawalAt) / 86400) >= 1;
  }

  function estimateInterestSingleNode(address _to, uint _nodeId, uint _timestamp) external view returns(uint) {
    require(_to != address(0), "_to is address 0");
    require(msg.sender == _to, 'Only this user can see their own funds.');
    Account storage account = accounts[_to];
    require(!account.archived, 'This account is blacklisted.');

    return estimateWithdrawAmountForNode(account, account.nodes[_nodeId], _timestamp);
  }

  function estimateInterestToWithdraw(address _to, uint _timestamp) external view returns(uint) {
    require(_to != address(0), "_to is address 0");
    require(msg.sender == _to, 'Only this user can see their own funds.');
    Account storage account = accounts[_to];
    require(!account.archived, 'This account is blacklisted.');

    return estimateWithdrawAmountForAccount(account, _timestamp);
  }

  function withdrawInterest(address _to) external {
    require(_to != address(0), "_to is address 0");
    require(msg.sender == _to, 'Only this user can widthraw their own funds.');
    Account storage account = accounts[_to];
    require(!account.archived, 'This account is blacklisted.');
    uint daysSinceLastWithdrawal = (block.timestamp - account.lastWithdrawalAt) / 86400;
    require(daysSinceLastWithdrawal >= 1, 'Interest accumulated must be greater than zero.');
    uint amount = estimateWithdrawAmountForAccount(account, block.timestamp);
    account.lastWithdrawalAt = block.timestamp;
    omAddress.transfer(_to, amount);
  }

  function estimateWithdrawAmountForAccount(Account storage _account, uint _timestamp) private view returns(uint) {
    uint amount = 0;
    for(uint i=0; i<_account.nodesLength; i++){
      Node memory node = _account.nodes[i];
      amount += estimateWithdrawAmountForNode(_account, node, _timestamp);
    }
    return amount;
  }

  function estimateWithdrawAmountForNode(Account storage _account, Node memory _node, uint _timestamp) private view returns(uint) {
    uint latestTimestamp;
    
    if(_node.createdAt <= _account.lastWithdrawalAt){
      latestTimestamp = _account.lastWithdrawalAt;
    }

    else {
      latestTimestamp = _node.createdAt;
    }

    uint reward;
    uint rotReachedTimestamp = _node.createdAt + rotTargetForNodes[_node.nodeType];

    if(_timestamp > rotReachedTimestamp && _account.lastWithdrawalAt < rotReachedTimestamp){
      uint amount;
      reward = nodeMultiplers[_node.nodeType] / 86400;
      amount = reward * (rotReachedTimestamp - _account.lastWithdrawalAt);

      if((_timestamp - rotReachedTimestamp) > cooldownTimeInSeconds) {
        reward = ((nodeMultiplers[_node.nodeType] / 86400) / 100) * percentageOfRewardAfterCooldown;
      }

      else {
        reward = ((nodeMultiplers[_node.nodeType] / 86400) / 100) * percentageOfRewardBeforeCooldown;
      }
      amount += reward * (_timestamp - rotReachedTimestamp);

      return amount;
    }

    else if(_timestamp > rotReachedTimestamp){
      
      if((_timestamp - _account.lastWithdrawalAt) > cooldownTimeInSeconds) {
        reward = ((nodeMultiplers[_node.nodeType] / 86400) / 100) * percentageOfRewardAfterCooldown;
      }

      else {
        reward = ((nodeMultiplers[_node.nodeType] / 86400) / 100) * percentageOfRewardBeforeCooldown;
      }

      return reward * (_timestamp - latestTimestamp);
    }

    else if(_timestamp <= rotReachedTimestamp){
      reward = nodeMultiplers[_node.nodeType] / 86400;
      
      return reward * (_timestamp - latestTimestamp);
    }

    else{
      revert("Couldn't handle timestamp provided");
    }
  }

  function transferOm(address _address, uint _amount) external {
    require(_address != address(0), "_address is address 0");
    require(msg.sender == owner, 'Only the owner can run this.');
    omAddress.transfer(_address, _amount);
  }

  function transferOx(address _address, uint _amount) external {
    require(_address != address(0), "_address is address 0");
    require(msg.sender == owner, 'Only the owner can run this.');
    oxAddress.transfer(_address, _amount);
  }

  function awardNode(address _address, uint _nodeType) external {
    require(_address != address(0), "_address is address 0");
    require(msg.sender == owner, 'Only the owner can run this.');
  require(_nodeType >= 0 && _nodeType <= 4, 'Invalid node type'); //their are 5 nodes
    // require(_nodeType >= 0 && _nodeType <= 7, 'Invalid node type'); //their are 5 nodes here its handling 8
    Account storage account;

    if(accounts[_address].exists){
      account = accounts[_address];
    }
    else{
      accounts[_address].exists = true;
      accounts[_address].nodesLength = 0;
      accounts[_address].lastWithdrawalAt = block.timestamp;
      accountAddresses.push(_address);
      account = accounts[_address];
    }

    require(account.nodesLength < accountNodeLimit, '100 node maximum already reached!');
    account.nodes[account.nodesLength] = Node(_nodeType, block.timestamp);
    account.nodesLength++;
    totalNodes++;
  }
}