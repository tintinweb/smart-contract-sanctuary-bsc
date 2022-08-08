// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeOwnable.sol";
import "./ERC721.sol";

contract FlyMoonCoinNFT is
    ERC721("FlyMoonCoinNFT", "FM-NFT"),
    SafeOwnable
{
    using SafeMath for uint256;
    using Strings for uint256;
    fallback() external payable {}
    receive() external payable {}
    mapping(address => bool) public isBind;
    mapping(address => address) public upLevelAdderss;
    mapping(address => address[]) public downLevelAdderss;
    mapping(address => uint) public downLevelCount;
    address[] public idoWhiteAddress;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _DLtotalSupply;
    mapping(address => uint256) private _DLbalances;
    mapping(address => PoolInfo) private poolInfos;
    address[] public rewardTokens;
    mapping(address => bool) public isIdoWhite;
    uint public whiteNum = 5;

    struct PoolInfo {
        bool enable;
        uint256 reserve;
        uint256 rewardLastStored;
        mapping(address => uint256) userRewardStored;
        mapping(address => uint256) newReward;
        mapping(address => uint256) claimedReward;
    }
    event AddPool(address indexed token);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(
        address indexed user,
        address indexed token,
        uint256 reward
    );
     function initialize()
        external
        onlyOwner
    {
        poolInfos[deadAddress].enable = true;
    }
      modifier updateDispatch(address account) {
            PoolInfo storage pool = poolInfos[deadAddress];
            if (pool.enable) {
                pool.rewardLastStored = rewardPer(pool);
                if (pool.rewardLastStored > 0) {
                    uint256 balance = address(this).balance;
                    pool.reserve = balance;
                    if (account != address(0)) {
                        pool.newReward[account] = available(deadAddress, account);
                        pool.userRewardStored[account] = pool.rewardLastStored;
                    }
                }
            }
        _;
    }
    function claimedReward(address account)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfos[deadAddress];
        return pool.claimedReward[account];
    }
    function lastReward(PoolInfo storage pool) private view returns (uint256) {
        if (_DLtotalSupply == 0) {
            return 0;
        }
        uint256 balance = address(this).balance;
        return balance.sub(pool.reserve);
    }

    function DLtotalSupply() public view returns (uint256) {
        return _DLtotalSupply;
    }

    function DLbalanceOf(address account) public view returns (uint256) {
        return _DLbalances[account];
    }

    function rewardPer(PoolInfo storage pool) private view returns (uint256) {
        if (DLtotalSupply() == 0) {
            return pool.rewardLastStored;
        }
        return
            pool.rewardLastStored.add(
                lastReward(pool).mul(1e18).div(DLtotalSupply())
            );
    }

    function stake(address account, uint256 amount)
        external
        updateDispatch(account)
    {
        _DLtotalSupply = _DLtotalSupply.add(amount);
        _DLbalances[account] = _DLbalances[account].add(amount);
        emit Staked(account, amount);
    }

    function withdraw(address account, uint256 amount)
        external
        updateDispatch(account)
    {
        if (_DLbalances[account] < amount) {
            amount = _DLbalances[account];
        }
        if (amount == 0) {
            return;
        }
        _DLtotalSupply = _DLtotalSupply.sub(amount);
        _DLbalances[account] = _DLbalances[account].sub(amount);
        emit Withdrawn(account, amount);
    }

    function available(address token, address account)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfos[token];
        return
            DLbalanceOf(account)
                .mul(rewardPer(pool).sub(pool.userRewardStored[account]))
                .div(1e18)
                .add(pool.newReward[account]);
    }

    function claim() external updateDispatch(msg.sender) {
        PoolInfo storage pool = poolInfos[deadAddress];
        uint256 reward = available(deadAddress, msg.sender);
        if (reward <= 0) {
            return;
        }
        pool.reserve = pool.reserve.sub(reward);
        pool.newReward[msg.sender] = 0;

        pool.claimedReward[msg.sender] = pool.claimedReward[msg.sender].add(
            reward
        );

        msg.sender.transfer(reward);
        emit RewardPaid(msg.sender, deadAddress, reward);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (from != address(0)) {
            this.withdraw(from, 1);
        }
        this.stake(to, 1);
    }

    function setWhiteNum(uint _whiteNum) public onlyOwner {
        whiteNum = _whiteNum;
    }
    
    function bindUpAddress(address upAddress) public returns (address){
        require(isBind[msg.sender] == false,"The current address is already bound");
        require(msg.sender != upAddress,"cannot bind yourself");
        upLevelAdderss[msg.sender] = upAddress;
        isBind[msg.sender] = true;
        return upAddress;
    }
    function isBindUpAddress(address sender) public view returns (bool){
        return isBind[sender];
    }
    function submitWhite(address whiteAddress) public {
        require(isIdoWhite[whiteAddress] == false,"address existed"); 
        if(msg.sender == owner()){
            idoWhiteAddress.push(whiteAddress);
            isIdoWhite[whiteAddress] = true;
            return;
        }

        require(downLevelCount[msg.sender] >= whiteNum,"downLevelCount scarcity");
        idoWhiteAddress.push(whiteAddress);
        downLevelCount[msg.sender] = downLevelCount[msg.sender].sub(whiteNum);
        isIdoWhite[whiteAddress] = true;
    }
    function getDownLevelCount(address sender) public view returns (uint){
        return downLevelCount[sender];
    }
    function getAllDownLevelAdd(address sender) public view returns (address[] memory){
        return downLevelAdderss[sender];
    }

    function getAllIdoWhiteAdd() public view returns (address[] memory){
        return idoWhiteAddress;
    }

    
    bool public _isSaleActive = false;
    bool public _revealed = false;
   
    uint256 public constant MAX_SUPPLY = 2000;
    uint256 public mintPrice = 0.3 ether;
   
    uint256 public maxMint = 10;
   
    string public notRevealedUri;
    string public baseExtension = ".txt";
   
    mapping(uint256 => string) private _tokenURIs;

    function reserveFM() public onlyOwner {
         require(
            totalSupply() <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
         uint256 mintIndex = totalSupply();
         _safeMint(msg.sender, mintIndex);

    }

    function mintNft(uint256 tokenQuantity) public payable {
         require(isBind[msg.sender] == true,"No bind up address");
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(_isSaleActive, "Sale must be active to mint NicMetas");
    
        require(
            tokenQuantity * mintPrice == msg.value,
            "Not enough ether sent"
        );
        require(tokenQuantity <= maxMint, "Can only mint 10 tokens at a time");
        uint256 sendBalance = msg.value;
        uint256 sendUpEth;
        if(balanceOf(upLevelAdderss[msg.sender]) > 0){
        sendUpEth = sendBalance.mul(30).div(100);
        payable(upLevelAdderss[msg.sender]).transfer(sendUpEth);
        }
        sendBalance = sendBalance.sub(sendUpEth);
        payable(owner()).transfer(sendBalance);
        _mintNft(tokenQuantity);
    }
   
    // 进行铸造
    function _mintNft(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
                downLevelAdderss[upLevelAdderss[msg.sender]].push(msg.sender);
                downLevelCount[upLevelAdderss[msg.sender]] = downLevelCount[upLevelAdderss[msg.sender]].add(1);
            }
        }
    }
   
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
   
        if (_revealed == false) {
            return notRevealedUri;
        }
   
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();
   
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }
   
   
    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }
   
    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }
   
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }
   
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
   
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
         _setBaseURI(_newBaseURI);
    }
   
    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }
   
   
    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }
}