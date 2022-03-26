// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./SafeERC20.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract FavaLaunchpad{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public owner;
    IERC20 rasingToken;

    struct Users{
        uint256 usedAllocation;
        bool claimed;
    }
    
    struct Projects{
        address tokenAdr;
        uint256 supply;
        uint256 soldAmount;
        uint256 saleStart;
        uint256 saleEnd;
        uint256 distributionDate;
        uint256 publicAllocation;
        uint256 price; //Per million tokens
        uint participants;
        bool withdrawn;
        mapping(address => Users) users;
    }

    mapping(address => Projects) public projects;

    constructor(address rasingTokenAdr){
        rasingToken = IERC20(rasingTokenAdr);
        owner = _msgSender();
    }

    function participate(address _ido,uint256 _amount) public returns(bool){
        Projects storage project = projects[_ido];
        require(project.supply > 0, "Project not found");
        require(_amount > 0, "Amount should be greater than 0");
        require(project.supply.sub(project.soldAmount) >= _amount, "Not enough supply");
        require(block.timestamp > project.saleStart && block.timestamp < project.saleEnd, "Invalid IDO time");
        require(project.publicAllocation >= project.users[_msgSender()].usedAllocation.add(_amount),
        "More allocation needed!");
        if(project.users[_msgSender()].usedAllocation == 0){
            project.participants++;
        }
        uint256 rasingTokenValue = (_amount.mul(project.price)) / 10 ** 6;
        rasingToken.safeTransferFrom(_msgSender(), address(this), rasingTokenValue);
        project.users[_msgSender()].usedAllocation = project.users[_msgSender()].usedAllocation.add(_amount);
        project.soldAmount = project.soldAmount.add(_amount);

        return true;
    }

    function claimTokens(address _ido) public returns(bool){
        Projects storage project = projects[_ido];
        require(project.supply > 0, "Project not found");
        require(block.timestamp > project.distributionDate);
        require(project.users[_msgSender()].claimed == false, "You already claimed your assets!");
        IERC20 token = IERC20(_ido);
        token.safeTransfer(_msgSender(), project.users[_msgSender()].usedAllocation);
        project.users[_msgSender()].claimed = true;
        
        return true;
    }

    function withdraw(address _ido,address payable _recipient) public onlyOwner {
        Projects storage project = projects[_ido];
        require(project.supply > 0, "Project not found");
        require(project.withdrawn == false, "Already withdrawn!");
        require(block.timestamp > project.saleEnd);
        rasingToken.safeTransfer(_recipient, (project.soldAmount.mul(project.price)) / 10 ** 6);
        project.withdrawn = true;
    }

    function usedAlloc(address _project) public view returns(uint256){
         return projects[_project].users[_msgSender()].usedAllocation;
    }

    function addIDO(address _tokenAdr,
                    uint256 _supply,
                    uint256 _saleStart,
                    uint256 _saleEnd,
                    uint256 _distributionDate,
                    uint256 _price,
                    uint256 _publicAllocation
                    )public onlyOwner{
        require(projects[_tokenAdr].supply == 0, "Project already exists");
        IERC20 token = IERC20(_tokenAdr);
        token.safeTransferFrom(_msgSender(), address(this), _supply);

        Projects storage project = projects[_tokenAdr];

        project.tokenAdr = _tokenAdr;
        project.supply = _supply;
        project.saleStart = _saleStart;
        project.saleEnd = _saleEnd;
        project.distributionDate = _distributionDate;
        project.price = _price;
        project.publicAllocation = _publicAllocation;
    }
    
    //let owner to change token addresses
    function setToken(address _token)public onlyOwner{
        rasingToken = IERC20(_token);
    }
    
    //let owner to change allocation
    function setAllocation(uint256 _allocation, address _ido) public onlyOwner{
        Projects storage project = projects[_ido];
        require(project.supply > 0, "Project not found");
        require(project.soldAmount < _allocation);
        project.publicAllocation = _allocation;
    }

    //Transfer Ownership
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0) && newOwner != address(1), "Ownable: new owner is the zero address");
        owner = newOwner;
    }

    modifier onlyOwner() {
        require(owner == _msgSender() || owner == address(0), "Ownable: caller is not the owner");
        _;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}