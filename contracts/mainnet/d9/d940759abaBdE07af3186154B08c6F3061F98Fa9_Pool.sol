// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Pool {
    struct Project{
        address owner;
        string pName;
        address tokenAddress;
        uint256 totalSupply;
        string chain;
        uint256 target;
        uint256 amountRaised;
        uint256 equivalentAmount;
        uint256 startingDate;
        bool status;
        uint256 airdropDate;
        bool airdropStatus;
        bool ended;

        address[] investors;
        uint256[] investments;
        address[] whitelist;

    }


    mapping(uint256 => Project) public projects;

    
    uint256 public numProjects = 0;


// implemented in JS
    function createProject(
        address _owner,
        string memory _pName,
        address _tokenAddress,
        uint256 _totalSupply,
        string memory _chain,
        uint256 _target,
        uint256 _amountRaised,
        uint256 _equivalentAmount
       
    ) public returns (uint256){
         Project storage project = projects[numProjects];
         project.owner = _owner;
         project.pName = _pName;
         project.tokenAddress = _tokenAddress;
         project.totalSupply = _totalSupply;
         project.chain = _chain;
         project.target = _target;
         project.amountRaised = _amountRaised;
         project.equivalentAmount = _equivalentAmount;
         project.startingDate = block.timestamp;
         project.ended = false;
        numProjects++;
        return numProjects - 1;

    }


    modifier activeProjectsOnly(uint256 _projectIndex) {
        // require(projects[_projectIndex].startingDate >= block.timestamp ,"The project is currently inactive");
        require(projects[_projectIndex].status,"The project is currently active");
      _;  
    }
    
    //  modifier inactiveProjectsOnly(uint256 _projectIndex) {
    //     require(!projects[_projectIndex].status,"The project is currently active");
    //   _;  
    // }



    modifier inactiveProjectsOnly(uint256 _projectIndex) {
        // require(projects[_projectIndex].startingDate < block.timestamp ,"The project is currently inactive");
        require(!projects[_projectIndex].status,"The project is currently active");
      _;  
    }

    modifier endedProject(uint256 _projectIndex) {
        // require(projects[_projectIndex].startingDate < block.timestamp ,"The project is currently inactive");
        require(projects[_projectIndex].ended,"The project is currently active");
      _;  
    }

    function addToWhitelist(uint256 _id, address user) public{
        projects[_id].whitelist.push(user);
    }

// implemented in JS
    function getNumOfProjects() public view returns(uint256){
        return numProjects;
    }

// implemented in JS
    function changeStatus(uint256 _projectIndex, bool _status) public returns(bool){
        projects[_projectIndex].status = _status;
        return projects[_projectIndex].status;
    }

     function endProject(uint256 _projectIndex, bool _status) public returns(bool){
        projects[_projectIndex].ended = _status;
        if (!_status){
         projects[_projectIndex].status = false;
        }
        return projects[_projectIndex].ended;
    }

// implemented in JS
    function setAirdropDate(uint256 _projectIndex, uint256 _airdropDate) public{
        projects[_projectIndex].airdropDate = _airdropDate;
    }

// implemented in JS
    function getAirdropDate(uint256 _projectIndex) public view returns(uint256){
        return projects[_projectIndex].airdropDate;
    }

// implemented in JS
    function addLiquidity(uint256 _projectIndex, address payable _investor, uint256 _amount) 
    public payable activeProjectsOnly(_projectIndex){

        Project storage project = projects[_projectIndex];
        project.investors.push (_investor);
        project.investments.push(_amount);

        (bool sent,) = payable(project.owner).call{value: _amount * 10**18}("");

       if(sent){    
            project.amountRaised = project.amountRaised + _amount;
       }

    }

// implemented in JS
    function numOfInvestments(uint256 id)view public returns(uint256){
        return(projects[id].investments.length );
    }


    function getAllInvestments(uint256 id, uint256 investmentNum) view public returns(address, uint256){
        require(projects[id].investments.length > 0,"No investment have been made");
        return(projects[id].investors[investmentNum] , projects[id].investments[investmentNum]);
    }

// implemented in JS
    function getActiveProject(uint256 id) view public
   returns (
         // address , //owner
        string memory, //pName
        // address, //tokenAddress
        // uint256, //totalSupply
        string memory, //chain
        uint256, //target
        // uint256, //amountRaised
        uint256 ,//equivalentAmount
        // uint256 //days since started
        bool,  //status
        uint256
        ){
            if(projects[id].status && !projects[id].ended){
        return (
            
      // projects[id].owner,  
        projects[id].pName,  
        // projects[id].tokenAddress,
        // projects[id].totalSupply,
        projects[id].chain,
        projects[id].target,
        // projects[id].amountRaised,
        projects[id].equivalentAmount,
        // (block.timestamp - projects[id].startingDate) / 60 /60 /24
        // block.timestamp - projects[id].startingDate //days since the project is up
        projects[id].status,
        id
        );
            }
    }

    
    function getUpcomingProject(uint256 id) view public 
    returns (
         // address , //owner
        string memory, //pName
        // address, //tokenAddress
        // uint256, //totalSupply
        string memory, //chain
        uint256, //target
        // uint256, //amountRaised
        uint256, //equivalentAmount
        // uint256 //days since started
        bool,     //status
        uint256
        ){
            if(!projects[id].status && !projects[id].ended){
        return (
      // projects[id].owner,  
        projects[id].pName,  
        // projects[id].tokenAddress,
        // projects[id].totalSupply,
        projects[id].chain,
        projects[id].target,
        // projects[id].amountRaised,
        projects[id].equivalentAmount,
        // (block.timestamp - projects[id].startingDate) / 60 /60 /24
        // block.timestamp - projects[id].startingDate //days since the project is up
        projects[id].status,
        id
        );
            }
        }

        function getEndedProject(uint256 id) view public
    returns (
        // address , //owner
        string memory, //pName
        // address, //tokenAddress
        // uint256, //totalSupply
        string memory, //chain
        uint256, //target
        // uint256, //amountRaised
        uint256, //equivalentAmount
        // uint256 ,//days since started
        bool,     //status
        uint256
        ){
            if(projects[id].ended){
        return (
        // projects[id].owner,  
        projects[id].pName,  
        // projects[id].tokenAddress,
        // projects[id].totalSupply,
        projects[id].chain,
        projects[id].target,
        // projects[id].amountRaised,
        projects[id].equivalentAmount,
        // (block.timestamp - projects[id].startingDate) / 60 /60 /24,
        // block.timestamp - projects[id].startingDate //days since the project is up
        projects[id].status,
        id
        );
        }
        }

       

    fallback() external payable {}

    receive() external payable {}
}