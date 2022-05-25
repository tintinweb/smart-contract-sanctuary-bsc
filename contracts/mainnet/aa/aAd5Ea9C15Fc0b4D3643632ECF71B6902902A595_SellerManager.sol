pragma solidity ^0.8.4;
import './SafeMath.sol';
import "./Ownable.sol";
import './IERC20.sol';

interface IERC721B {
    function mintInvite(address user, uint256 quantity) external payable;
    function mintBatch(address user, uint256 types, uint256 quantity) external payable;
    function nextId() external view returns (uint256);
    function MAX() external view returns (uint256);
    function canMintInvite(uint256 quantity) external view returns (bool);
}

contract SellerManager is Ownable{
    using SafeMath for uint256;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    uint256 public amount = 100 * 1e18;
    bool public pubsell = false;

    address public seller = 0x020d2F2C8b3593Bc229B67e6e720C2a822DD8895;
    address public DEAULT_INVITER = 0xf727951b479545F25C4BdC1F12329bb15c5DB2D9;
    IERC721B public box;// = IERC721B(0x0);

    mapping (address => uint256) public publicBuyNum;

    mapping(address => uint) public inviteBuyNum;
    mapping(address => uint) public inviteBackNum;
    mapping(address => uint) public inviteNumMap;
    //self -> inviter
    mapping (address => address) public inviteMap;
    //self ->myinvites
    mapping (address => address[]) public invitedUsersMap;

    constructor(address box_, address usdt_) public{
        box = IERC721B(box_);
        usdt = usdt_;
    }

    function setAmount(uint256 _amount) public onlyOwner {
        amount = _amount;
    }

    function setBoxContract(address mimi)  public onlyOwner{
        box = IERC721B(mimi);
    }

    event onBuy(address user, uint256 types, uint256 quantity);
    event onBind(address user, address inviter);
    event onBack(address user, address inviter, uint256 quantity);

    function buyBox(uint256 types, uint256 quantity, address lastUser) payable public onlyPubsell  {
        require(quantity >= 1, 'you buy num is 0');
        IERC20(usdt).transferFrom(msg.sender, seller, amount * quantity);
        box.mintBatch(msg.sender, types, quantity);
        publicBuyNum[msg.sender] = publicBuyNum[msg.sender] + quantity;
        emit onBuy(msg.sender, types, quantity);

        address inviter = inviteMap[msg.sender];
        if(inviter == address(0)){
            if(lastUser == address(0) || msg.sender == lastUser){
                inviter = DEAULT_INVITER;
            }else{
                inviter = lastUser;
            }
            inviteNumMap[inviter] = inviteNumMap[inviter].add(1);
            inviteMap[msg.sender] = inviter;
            invitedUsersMap[inviter].push(msg.sender);
            emit onBind(msg.sender, inviter);
        }

        uint256 inviteBuyTotal = inviteBuyNum[inviter].add(quantity);
        if(inviteBuyTotal >= 10 ){
            uint256 backNum = inviteBuyTotal / 10;
            if(box.canMintInvite(backNum)){
                box.mintInvite(inviter, backNum);
                inviteBuyNum[inviter] = inviteBuyTotal - 10*backNum;
                inviteBackNum[inviter] = inviteBackNum[inviter].add(backNum);
                emit onBack(msg.sender, inviter, backNum);
            }
        }else{
            inviteBuyNum[inviter] = inviteBuyTotal;
        }
    }

    function getInvited() public view returns(address[] memory,uint256[] memory) {
        address[] memory myInvitedUsers = invitedUsersMap[msg.sender];
        uint256[] memory buyNums = new uint256[](myInvitedUsers.length);
        for(uint256 i = 0; i < myInvitedUsers.length; i++) {
            buyNums[i] = publicBuyNum[myInvitedUsers[i]];
        }
        return (myInvitedUsers,buyNums);
    }

    function setPubsell(bool work_) public onlyOwner {
        pubsell = work_;
    }

    modifier onlyPubsell() {
        require(pubsell == true, 'not open sell');
        _;
    }

}