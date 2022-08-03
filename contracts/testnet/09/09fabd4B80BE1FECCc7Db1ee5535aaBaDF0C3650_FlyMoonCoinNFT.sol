// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeOwnable.sol";
import "./ERC721.sol";
//import "./SmartDisPatchInitializable.sol";

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
    /*************************************************************************************************************/
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _DLtotalSupply;
    mapping(address => uint256) private _DLbalances;
    mapping(address => PoolInfo) private poolInfos;
    address[] public rewardTokens;
    uint public whiteNum = 5;

    struct PoolInfo {
        bool enable;
        //IERC20 rewardToken;
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
        //require(msg.sender == SMART_DISPATCH_FACTORY, "Not factory");
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

        //pool.rewardToken.safeTransfer(msg.sender, reward);
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
    
    //绑定上级
    function bindUpAddress(address upAddress) public returns (address){
        require(isBind[msg.sender] == false,"The current address is already bound");
        require(msg.sender != upAddress,"cannot bind yourself");
        upLevelAdderss[msg.sender] = upAddress;
        isBind[msg.sender] = true;
        return upAddress;
    }
    //查询是否绑定
    function isBindUpAddress(address sender) public view returns (bool){
        return isBind[sender];
    }
    //提交白名单
    function submitWhite(address whiteAddress) public {
        if(msg.sender == owner()){
            idoWhiteAddress.push(whiteAddress);
            return;
        }
        require(downLevelCount[msg.sender] >= whiteNum,"downLevelCount scarcity");
        idoWhiteAddress.push(whiteAddress);
        downLevelCount[msg.sender] = downLevelCount[msg.sender].sub(whiteNum);
    }
    //查询下级铸造的数量
    function getDownLevelCount(address sender) public view returns (uint){
        return downLevelCount[sender];
    }

    /*************************************************************************************************************/
    
    // 是否准许nft开卖-开关
    bool public _isSaleActive = false;
    // 初始化盲盒，等到一定时机可以随机开箱，变成true
    bool public _revealed = false;
   
    // nft的总数量
    uint256 public constant MAX_SUPPLY = 2000;
    // 铸造Nft的价格
    uint256 public mintPrice = 0.003 ether;
   
    // 一次mint的nft的数量
    uint256 public maxMint = 10;
   
    // 盲盒开关打开后，需要显示开箱的图片的base地址
    // 盲盒图片的meta,txt地址，后文会提到
    string public notRevealedUri;
    // 默认地址的扩展类型
    string public baseExtension = ".txt";
   
    mapping(uint256 => string) private _tokenURIs;

    // 外部地址进行铸造nft的函数调用
    function mintNft(uint256 tokenQuantity) public payable {
         require(isBind[msg.sender] == true,"No bind up address");
        // 校验总供应量+每次铸造的数量<= nft的总数量
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        // 校验是否开启开卖状态
        require(_isSaleActive, "Sale must be active to mint NicMetas");
    
        // 校验本次铸造的数量*铸造的价格 == 本次消息附带的eth的数量
        require(
            tokenQuantity * mintPrice == msg.value,
            "Not enough ether sent"
        );
        // 校验本次铸造的数量 <= 本次铸造的最大数量
        require(tokenQuantity <= maxMint, "Can only mint 10 tokens at a time");
        uint256 sendBalance = msg.value;
        uint256 sendUpEth;
        if(balanceOf(upLevelAdderss[msg.sender]) > 0){
        //给上级发送的数量
        sendUpEth = sendBalance.mul(30).div(100);
        payable(upLevelAdderss[msg.sender]).transfer(sendUpEth);
        }
        //剩下的给owner
        sendBalance = sendBalance.sub(sendUpEth);
        payable(owner()).transfer(sendBalance);
        // 以上校验条件满足，进行nft的铸造
        _mintNft(tokenQuantity);
    }
   
    // 进行铸造
    function _mintNft(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            // mintIndex是铸造nft的序号，按照总供应量从0开始累加
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                // 调用erc721的安全铸造方法进行调用
                _safeMint(msg.sender, mintIndex);
                downLevelAdderss[upLevelAdderss[msg.sender]].push(msg.sender);
                downLevelCount[upLevelAdderss[msg.sender]] = downLevelCount[upLevelAdderss[msg.sender]].add(1);
            }
        }
    }
   
    // 返回每个nft地址的Uri，这里包含了nft的整个信息，包括名字，描述，属性等
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
   
        // 盲盒还没开启，那么默认是一张黑色背景图片或者其他图片
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