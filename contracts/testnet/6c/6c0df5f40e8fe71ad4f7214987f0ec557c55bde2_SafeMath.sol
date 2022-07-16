/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account));
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account));
        role.bearer[account] = false;
    }

    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract ApproverRole {
    using Roles for Roles.Role;

    event ApproverAdded(address indexed account);
    event ApproverRemoved(address indexed account);

    Roles.Role private _approvers;

    address firstSignAddress;
    address secondSignAddress;

    mapping(address => bool) signed; // Signed flag

    constructor() {
        _addApprover(msg.sender);

        firstSignAddress = 0x6f5AbAa7692Ee4bE69c84E4465D282204859bc04; // You should change this address to your first sign address
        secondSignAddress = 0xDD45BaE748b8Ca386b43301aC353AF02a950a74d; // You should change this address to your second sign address
    }

    modifier onlyApprover() {
        require(isApprover(msg.sender));
        _;
    }

    function sign() external {
        require(
            msg.sender == firstSignAddress || msg.sender == secondSignAddress
        );
        require(!signed[msg.sender]);
        signed[msg.sender] = true;
    }

    function isApprover(address account) public view returns (bool) {
        return _approvers.has(account);
    }

    function addApprover(address account) external onlyApprover {
        require(signed[firstSignAddress] && signed[secondSignAddress]);
        _addApprover(account);

        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function removeApprover(address account) external onlyApprover {
        require(signed[firstSignAddress] && signed[secondSignAddress]);
        _removeApprover(account);

        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function renounceApprover() external {
        require(signed[firstSignAddress] && signed[secondSignAddress]);
        _removeApprover(msg.sender);

        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function _addApprover(address account) internal {
        _approvers.add(account);
        emit ApproverAdded(account);
    }

    function _removeApprover(address account) internal {
        _approvers.remove(account);
        emit ApproverRemoved(account);
    }
}

library SafeMath {
    function safeAdd(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) external pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) external pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract MainContract is ApproverRole, ReentrancyGuard {
    using SafeMath for uint256;
    struct AccountData {
        uint8 accountType; // 0 => Freelancer, 1 => Approver, 2 => Customer
        address personWalletAddress;
        uint256 personWorkCount;
        uint256[] personPuan; // Rate x/5
        address[] WorkAddresses; // All work addresses
        string personInfoData;
    }

    mapping(address => AccountData) accounts;
    mapping(address => bool) personsAddress;
    mapping(address => uint256) public feeRates;
    mapping(address => bool) public availableTokens;
    mapping(address => uint256) public approverLockBalances;
    mapping(address => bool) public isDeployedWorks;

    uint256 public bnbFeeRate;
    uint256 public remainingBratsToken;
    uint256 public approverMinBratsLimit;
    address[] public deployedWorks;
    address[] public allPersons;
    address public feeAddress;
    address public bratsTokenContractAddress;
    bool public isActive;
    IBEP20 public bratsToken; // BratsToken Contract Address

    modifier isInAccounts() {
        require(personsAddress[msg.sender]);
        _;
    }

    modifier mustApprover() {
        require(personsAddress[msg.sender]);
        AccountData storage data = accounts[msg.sender];
        require(data.accountType == 1);
        _;
    }

    modifier mustActive() {
        require(isActive);
        _;
    }

    constructor(
        address _bratsTokenAddress,
        uint256 _bnbFeeRate,
        address _feeAddress
    ) {
        bratsToken = IBEP20(_bratsTokenAddress);
        bnbFeeRate = _bnbFeeRate;
        remainingBratsToken = 5e6 ether;
        approverMinBratsLimit = 20 * 10**18;
        feeAddress = _feeAddress;
        bratsTokenContractAddress = _bratsTokenAddress;
    }

    function changeActive(bool _active) external onlyApprover {
        isActive = _active;
    }

    function changeAvailableTokenFee(
        address _tokenAddress,
        uint256 _feeRate,
        bool _available
    ) external onlyApprover {
        feeRates[_tokenAddress] = _feeRate;
        availableTokens[_tokenAddress] = _available;
    }

    function changeSettings(
        uint256 _approverMinBratsLimit,
        uint256 _bnbFeeRate,
        address _feeAddress
    ) external onlyApprover {
        approverMinBratsLimit = _approverMinBratsLimit;
        bnbFeeRate = _bnbFeeRate;
        feeAddress = _feeAddress;
    }

    function sendBratsTokenAdmin(address _address, uint256 amount)
        external
        onlyApprover
        nonReentrant
    {
        bratsToken.transfer(_address, amount);
    }

    function unLock() external mustApprover nonReentrant {
        require(approverLockBalances[msg.sender] > 0);
        AccountData storage data = accounts[msg.sender];
        require(data.WorkAddresses.length == 0);
        delete accounts[msg.sender];
        personsAddress[msg.sender] = false;
        for (uint256 x = 0; x < allPersons.length; x++) {
            if (allPersons[x] == msg.sender) {
                delete allPersons[x];
            }
        }
        bratsToken.transfer(msg.sender, approverLockBalances[msg.sender]);
        approverLockBalances[msg.sender] = 0;
    }

    function getAllPersons() external view returns (address[] memory) {
        return allPersons;
    }

    function addPerson(uint8 _accountType, string memory _personInfoData)
        external
        mustActive
        nonReentrant
    {
        if (_accountType == 1) {
            approverLockBalances[msg.sender] = approverLockBalances[msg.sender]
                .safeAdd(approverMinBratsLimit);
            require(
                bratsToken.transferFrom(
                    msg.sender,
                    address(this),
                    approverMinBratsLimit
                )
            );
        }
        require(!personsAddress[msg.sender]);
        AccountData memory newAccount = AccountData({
            accountType: _accountType,
            personWalletAddress: msg.sender,
            personWorkCount: 0,
            personPuan: new uint256[](0),
            WorkAddresses: new address[](0),
            personInfoData: _personInfoData
        });

        accounts[msg.sender] = newAccount; // Adding a new account
        allPersons.push(msg.sender); // Adding a new account
        personsAddress[msg.sender] = true;
    }

    function getPersonInfoData(address _personAddress)
        external
        view
        returns (
            uint8,
            uint256,
            uint256[] memory,
            address[] memory,
            string memory
        )
    {
        AccountData storage data = accounts[_personAddress];
        return (
            data.accountType,
            data.personWorkCount,
            data.personPuan,
            data.WorkAddresses,
            data.personInfoData
        );
    }

    function getPersonAccountType(address _personAddress)
        public
        view
        returns (uint8)
    {
        AccountData storage data = accounts[_personAddress];
        return data.accountType;
    }

    function updatePerson(string memory _personInfoData)
        external
        isInAccounts
        mustActive
    {
        AccountData storage data = accounts[msg.sender];
        data.personInfoData = _personInfoData;
    }

    function createWork(
        string memory _workTitle,
        string memory _workCategory,
        string memory _workDescription,
        uint256  _workAvarageBudget
    ) external mustActive {
        AccountData storage data = accounts[msg.sender];
        require(getPersonAccountType(msg.sender) == 2);
        WorkContract newWork = new WorkContract(
            _workTitle,
            _workCategory,
            _workDescription,
            _workAvarageBudget,
            payable(msg.sender),
            address(this)
        );
        data.WorkAddresses.push(); // Adding Person Works
        deployedWorks.push(); // Adding All Works
        isDeployedWorks[address(newWork)] = true;
    }

    function getWorks() external view returns (address[] memory) {
        return deployedWorks;
    }

    function setPuan(uint256 _puan, address payable _freelancerAddress)
        external
    {
        require(isDeployedWorks[msg.sender]);
        AccountData storage data = accounts[_freelancerAddress];
        data.personPuan.push(_puan);
    }

    function setApproverWorkAddress(
        address _workAddress,
        address _approveraddress
    ) external {
        require(isDeployedWorks[msg.sender]);

        AccountData storage data = accounts[_approveraddress];
        data.WorkAddresses.push(_workAddress);
    }

    function setFreelancerWorkAddress(
        address _workAddress,
        address payable _freelanceraddress
    ) external {
        require(isDeployedWorks[msg.sender]);

        AccountData storage data = accounts[_freelanceraddress];
        data.WorkAddresses.push(_workAddress);
    }

    function _removeApproverWorkAddressArray(
        uint256 index,
        address _approveraddress
    ) private {
        AccountData storage data = accounts[_approveraddress];

        if (index >= data.WorkAddresses.length) return;

        for (uint256 i = index; i < data.WorkAddresses.length - 1; i++) {
            data.WorkAddresses[i] = data.WorkAddresses[i + 1];
        }
        delete data.WorkAddresses[data.WorkAddresses.length - 1];
        data.WorkAddresses.length;
    }

    function deleteApproverWorkAddress(
        address _workAddress,
        address _approveraddress
    ) external {
        require(isDeployedWorks[msg.sender]);

        AccountData storage data = accounts[_approveraddress];
        for (uint256 i = 0; i < data.WorkAddresses.length; i++) {
            if (data.WorkAddresses[i] == _workAddress) {
                _removeApproverWorkAddressArray(i, _approveraddress);
            }
        }
    }

    function checkDeadline(address _workAddress)
        external
        view
        returns (bool, address)
    {
        WorkContract deployedWork;
        deployedWork = WorkContract(_workAddress);
        if (
            block.timestamp > deployedWork.deadLine() &&
            deployedWork.deadLine() != 0
        ) {
            return (true, _workAddress);
        } else {
            return (false, _workAddress);
        }
    }

    function sendApproverBratsCoin(address _approveraddress) external {
        require(isDeployedWorks[msg.sender]);

        uint256 amount = (remainingBratsToken.safeMul(3)).safeDiv(1e5);
        bratsToken.transfer(_approveraddress, amount);
        remainingBratsToken = remainingBratsToken.safeSub(amount);
    }
}

contract WorkContract is ApproverRole, ReentrancyGuard {
    using SafeMath for uint256;

    MainContract deployedFromContract;
    struct Offer {
        uint256 offerPrice;
        address payable freelancerAddress;
        string description;
        string title;
        uint256 deadline;
        address offerTokenContract;
        bool tokenContractIsBNB;
        bool BratsShield;
    }

    string public workTitle;
    string public workCategory;
    string public workDescription;
    uint256 public workAvarageBudget;
    string public workFilesLink;
    string public employerCancelDescription;
    string public approverReport;
    string public employerRemark;

    uint256 public workCreateTime;
    uint256 public deadLine;
    uint256 public freelancerSendFilesDate;
    uint256 public workStartDate;
    uint256 public workEndDate;
    uint256 public approverConfirmStatus;
    uint256 public approverStartDate;
    uint256 public workPrice;
    uint256 public workOfferCount;

    bool public workStatus;
    bool public isBNB;
    bool public bratsShield;
    bool public freelancerSendFiles;
    bool public employerReceiveFiles;

    address public employerAddress;
    address public approverAddress;
    address public tokenContractAddress;
    address payable public freelancerAddress;
    address[] public allFreelancerAddress;

    IBEP20 public bratsToken; // BratsToken Contract
    mapping(address => Offer) offers;

    modifier mustActive() {
        require(deployedFromContract.isActive());
        _;
    }

    modifier requireForApprover() {
        require(approverConfirmStatus == 0 && approverStartDate > 0);
        require(bratsShield);
        _;
    }

    constructor(
        string memory _workTitle,
        string memory _workCategory,
        string memory _workDescription,
        uint256  _workAvarageBudget,
        address _employerAddress,
        address _t
    ) {
        require(MainContract(_t).isActive());
        require(MainContract(_t).getPersonAccountType(_employerAddress) == 2);
        workTitle = _workTitle;
        workCategory = _workCategory;
        workDescription = _workDescription;
        workCreateTime = block.timestamp;
        workAvarageBudget = _workAvarageBudget;
        workOfferCount = 0;
        workStatus = false;
        employerAddress = _employerAddress;
        freelancerSendFiles = false;
        employerReceiveFiles = false;
        deployedFromContract = MainContract(_t);
        bratsToken = IBEP20(MainContract(_t).bratsTokenContractAddress());
    }

    function getWorkData()
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        return (
            workTitle,
            workDescription,
            workCreateTime,
            workAvarageBudget,
            workOfferCount,
            workStatus
        );
    }

    function getAllFreelancers() external view returns (address[] memory) {
        return allFreelancerAddress;
    }

    function updateWork(
        string memory _workTitle,
        string memory _workCategory,
        string memory _workDescription,
        uint256 _workAvarageBudget,
        address _workaddress
    ) external mustActive {
        require(address(this) == _workaddress);
        require(msg.sender == employerAddress);
        workTitle = _workTitle;
        workCategory = _workCategory;
        workDescription = _workDescription;
        workAvarageBudget = _workAvarageBudget;
    }

    function createOffer(
        uint256 _offerPrice,
        string memory _description,
        uint256 _deadline,
        string memory _title,
        address _tokenContract,
        bool _isBNB,
        bool _BratsShield
    ) external mustActive {
        require(deployedFromContract.getPersonAccountType(msg.sender) == 0);
        if (!_isBNB) {
            require(_tokenContract != address(0));
            require(deployedFromContract.availableTokens(_tokenContract));
        }
        Offer memory newOffer = Offer({
            offerPrice: _offerPrice,
            freelancerAddress: payable(msg.sender),
            description: _description,
            deadline: _deadline,
            title: _title,
            offerTokenContract: _tokenContract,
            tokenContractIsBNB: _isBNB,
            BratsShield: _BratsShield
        });
        offers[msg.sender] = newOffer;
        allFreelancerAddress.push(msg.sender);
        workOfferCount++;
    }

    function deleteOffer() external mustActive {
        delete offers[msg.sender];
        workOfferCount--;
    }

    function updateOffer(
        uint256 _offerPrice,
        string memory _description,
        string memory _title,
        bool _BratsShield
    ) external mustActive {
        Offer storage data = offers[msg.sender];
        data.offerPrice = _offerPrice;
        data.description = _description;
        data.title = _title;
        data.BratsShield = _BratsShield;
    }

    function getOfferData(address payable _freelancerAddress)
        external
        view
        returns (
            uint256,
            address,
            string memory,
            string memory,
            uint256,
            address,
            bool,
            bool
        )
    {
        Offer storage data = offers[_freelancerAddress];
        return (
            data.offerPrice,
            data.freelancerAddress,
            data.description,
            data.title,
            data.deadline,
            data.offerTokenContract,
            data.tokenContractIsBNB,
            data.BratsShield
        );
    }

    function selectOffer(
        address payable _freelancerAddress,
        address _approveraddress
    ) external payable mustActive {
        require(msg.sender == employerAddress);
        Offer storage data = offers[_freelancerAddress];
        require(data.tokenContractIsBNB);
        deployedFromContract.setFreelancerWorkAddress(
            address(this),
            payable(_freelancerAddress)
        );
        if (data.BratsShield) {
            require(
                deployedFromContract.approverLockBalances(_approveraddress) >=
                    deployedFromContract.approverMinBratsLimit()
            );
            approverAddress = _approveraddress;
            deployedFromContract.setApproverWorkAddress(
                address(this),
                _approveraddress
            );
        }

        require(msg.value >= data.offerPrice);
        freelancerAddress = data.freelancerAddress;
        workStatus = true;
        workStartDate = block.timestamp;
        deadLine = data.deadline;
        workPrice = data.offerPrice;
        isBNB = true;
        bratsShield = data.BratsShield;
    }

    function selectOfferWithToken(
        address payable _freelancerAddress,
        address _approveraddress
    ) external mustActive {
        require(msg.sender == employerAddress);
        Offer storage data = offers[_freelancerAddress];
        require(!data.tokenContractIsBNB);
        deployedFromContract.setFreelancerWorkAddress(
            address(this),
            payable(_freelancerAddress)
        );
        if (data.BratsShield) {
            require(
                deployedFromContract.approverLockBalances(_approveraddress) >=
                    deployedFromContract.approverMinBratsLimit()
            );

            approverAddress = _approveraddress;
            deployedFromContract.setApproverWorkAddress(
                address(this),
                _approveraddress
            );
        }
        freelancerAddress = data.freelancerAddress;
        workStatus = true;
        workStartDate = block.timestamp;
        deadLine = data.deadline;
        workPrice = data.offerPrice;
        isBNB = false;
        tokenContractAddress = data.offerTokenContract;
        require(
            IBEP20(data.offerTokenContract).transferFrom(
                msg.sender,
                address(this),
                data.offerPrice
            )
        );
        bratsShield = data.BratsShield;
    }

    function freelancerSendFile(string memory _workFilesLink) external {
        require(msg.sender == freelancerAddress);
        require(!freelancerSendFiles);
        freelancerSendFiles = true;
        workFilesLink = _workFilesLink;
        freelancerSendFilesDate = block.timestamp;
    }

    function _payFreelancer() private {
        uint256 amount;

        if (isBNB) {
            amount = workPrice.safeSub(
                (workPrice.safeMul(deployedFromContract.bnbFeeRate())).safeDiv(
                    1e6
                )
            );
            payable(freelancerAddress).transfer(amount);
            /* deployedFromContract.feeAddress().transfer(
                workPrice.safeSub(amount)
            );*/
        } else {
            amount = workPrice.safeSub(
                (
                    workPrice.safeMul(
                        deployedFromContract.feeRates(tokenContractAddress)
                    )
                ).safeDiv(1e6)
            );

            IBEP20(tokenContractAddress).transfer(freelancerAddress, amount);
            IBEP20(tokenContractAddress).transfer(
                deployedFromContract.feeAddress(),
                workPrice.safeSub(amount)
            );
        }
    }

    function _payEmployer() private {
        if (isBNB) {
            payable(employerAddress).transfer(workPrice);
        } else {
            IBEP20(tokenContractAddress).transfer(employerAddress, workPrice);
        }
    }

    function employerReceiveFile(uint256 _puan, string memory _remark)
        external
        nonReentrant
    {
        require(msg.sender == employerAddress);
        require(freelancerSendFiles, "freelancer must be sent files");
        require(!employerReceiveFiles);
        _payFreelancer();
        deployedFromContract.setPuan(_puan, freelancerAddress);
        employerRemark = _remark;
        employerReceiveFiles = true;
        workEndDate = block.timestamp;
    }

    function employerCancel(string memory _depscription) external {
        require(msg.sender == employerAddress);
        require(bratsShield);
        require(approverStartDate == 0);
        require(!employerReceiveFiles);
        require(freelancerSendFiles, "freelancer must be sent files");

        approverConfirmStatus = 0;
        employerCancelDescription = _depscription;
        approverStartDate = block.timestamp;
    }

    function confirmApprover(string memory _description)
        external
        nonReentrant
        requireForApprover
    {
        if (block.timestamp > approverStartDate.safeAdd(5 days)) {
            require(isApprover(msg.sender));
        } else {
            require(msg.sender == approverAddress);

            deployedFromContract.deleteApproverWorkAddress(
                address(this),
                approverAddress
            );

            deployedFromContract.sendApproverBratsCoin(approverAddress);
        }

        approverConfirmStatus = 1;
        _payFreelancer();
        approverReport = _description;
        workEndDate = block.timestamp;
    }

    function cancelApprover(string memory _description)
        external
        nonReentrant
        requireForApprover
    {
        if (block.timestamp > approverStartDate.safeAdd(5 days)) {
            require(isApprover(msg.sender));
        } else {
            require(msg.sender == approverAddress);
            deployedFromContract.deleteApproverWorkAddress(
                address(this),
                approverAddress
            );
            deployedFromContract.sendApproverBratsCoin(approverAddress);
        }
        approverConfirmStatus = 2;
        approverReport = _description;
        _payEmployer();
    }

    function autoConfirm() external nonReentrant {
        require(block.timestamp > freelancerSendFilesDate.safeAdd(5 days));
        require(!employerReceiveFiles);
        require(freelancerSendFiles);
        _payFreelancer();
        deployedFromContract.setPuan(5, freelancerAddress);
        employerRemark = "Auto Confirmed By Smart Contract";
        workEndDate = block.timestamp;
    }

    function sendDeadline() external nonReentrant {
        require(block.timestamp > deadLine);
        require(!freelancerSendFiles);
        _payEmployer();
    }
}