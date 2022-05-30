    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.7;

    import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

    /// @title Unremot Contract for Developer's Code NFT Program
    /// @author Himanshu Gautam
    /// @dev Contract based in ERC 1155 Token Standards
    contract Unremot is ERC1155 {
     
    uint _tokenIds; 
    uint public _listPrice; 
    uint public _mintPrice; 
    string public name;
    string public symbol;
    address public admin; 
    address public owner; 

    /// @dev Mapping to store github repo link as token URI 
    mapping (uint256 => string) private _tokenURI;
    /// @dev Mapping to store allowances of NFT sales to marketplace
    mapping(address => mapping(uint256 => uint256)) allowances;

    event Mint(address _from, uint indexed tokenId, uint amount, string tokenURI);
    event ChangeOwner(address newOwner,address oldowner);
    event ChangeAdmin(address newAdmin,address oldadmin);
    event OwnershipTransfer(address from,address to, uint indexed tokenId, uint amount);
    event ApproveOwnership(address sender);
    event NFTPayment(address indexed sender, uint value);
    event ListingPrice(uint newListPrice, uint _oldListPrice);
    event MintingPrice(uint newMintPrice, uint _oldMintPrice);    
    event BurnNFT(address account,uint id,uint amount);
    event Withdrawal(uint amount);
    event Received(address sender, uint amount);
    event Fallback(address sender, uint amount);

    /// @dev Constructor Function to assign contract owner and admin 
    /// @param _admin Contract Admin address
    constructor(address _admin) ERC1155("") {
            name = 'Unremot_Contract';
            symbol = 'Programming NFT';
            owner = msg.sender;
            admin = _admin;
            _tokenIds = 1;
            _listPrice = 0;
            _mintPrice = 0;
    }

    /// @dev Modifier to give access to owner only
    modifier onlyOwner {
    require(msg.sender == owner, "Not market owner"); 
      _;
    }

    /// @dev Modifier to give access to owner only
    modifier onlyAdmin {
    require(msg.sender == admin, "Not market admin"); 
      _;
    }
    
    /// @dev Function to change owner of contract
    /// @param _newOwner Contract new owner address
    function changeOwner(address _newOwner) external onlyAdmin{
        emit ChangeOwner(_newOwner, owner);
        owner = _newOwner;
    }

    /// @dev Function to change admin of contract
    /// @param _newAdmin Contract new admin address
    function changeAdmin(address _newAdmin) external onlyAdmin{
        emit ChangeAdmin(_newAdmin, admin);
        admin = _newAdmin;
    }

    /// @dev Function to change listing price
    /// @param listPrice New listing price
    function setListingPrice(uint256 listPrice) external onlyOwner{
        emit ListingPrice(listPrice, _listPrice);
        _listPrice = listPrice;
    }

    /// @dev Function to change minting price
    /// @param mintPrice New Mint price
    function setMintingPrice(uint256 mintPrice) external onlyOwner{
        emit MintingPrice(mintPrice, _mintPrice);
        _mintPrice = mintPrice;
    }

    /// @dev Function to mint NFT tokens
    /// @param _amount Number of NFT tokens to be minted
    /// @param _uriDetail Token URI of NFT - Github link
    function mint(uint256 _amount, string memory _uriDetail) external payable{
        require(msg.value >= _mintPrice, "Insufficient funds for minting");    
        require(owner != msg.sender, "Owner cannot mint NFTs");    
        _mint(msg.sender, _tokenIds , _amount, bytes('0x0'));
        _tokenURI[_tokenIds] = _uriDetail; 
        setApprovalForAll(owner, true);
        allowances[msg.sender][_tokenIds] = _amount;
        emit Mint(msg.sender, _tokenIds, _amount, _uriDetail);
        _tokenIds++ ;
    }

    /// @dev Function to transfer ownership of NFTs
    /// @param _tokenId Token Id
    /// @param _from NFT seller address
    /// @param _to NFT buyer address
    function transferOwnership(uint256 _tokenId, address _from, address _to) external onlyOwner{
        require(allowances[_from][_tokenId] > 0, "No existing approvals");  
        allowances[_from][_tokenId] = allowances[_from][_tokenId] - 1;       
        safeTransferFrom(_from, _to, _tokenId, 1, bytes('0x0')); // bytes()
        emit OwnershipTransfer(_from, _to, _tokenId, 1);
    }

    /// @dev Function to get allowance to marketplace for NFT secondary sale
    /// @param _tokenID NFT Id 
    /// @param _amount Amount of NFT token given allowance
    function approveOwnership(uint _tokenID, uint _amount) external payable{
        require(msg.value >= _listPrice, "Insufficient funds for listing");    
        setApprovalForAll(owner, true);
        allowances[msg.sender][_tokenID] = allowances[msg.sender][_tokenID] + _amount;
        emit ApproveOwnership(msg.sender);
    }

    /// @dev Function to get allowance status of NFT 
    /// @param _tokenID NFT Id 
    /// @param _sender Address with given allowance
    function getApproveOwnership(uint _tokenID, address _sender) external view returns (uint){
        return(allowances[_sender][_tokenID]);
    }

    /// @dev Function to receive payment from Client purchasing NFT
    function buyNFT() external payable{
        require(msg.value > 0 , "Insufficient funds for NFT purchase");    
        emit NFTPayment(msg.sender, msg.value);
    }

    /// @dev Function to get token URI of NFT - github link 
    /// @param _tokenId Token Id of NFT
    function getUri(uint256 _tokenId) external onlyOwner view returns (string memory) {
        return(_tokenURI[_tokenId]);
    }

    /// @dev Function to allow NFT burn by Owner
    /// @param _account Address from where NFT has to be burn
    /// @param _id Token Id of NFT
    /// @param _amount Amount of NFTs to be burn
    function burnNFT(address _account, uint256 _id, uint256 _amount) external onlyOwner{
        _burn(_account, _id, _amount);
        emit BurnNFT( _account, _id, _amount);
    }

    /// @dev Function to handle calls to contract without any data like send() transfer()
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// @dev Function to handle non existent function identifier calls or wrong data calls
    fallback() external payable {
        emit Fallback(msg.sender, msg.value);
    }

    /// @dev Function to withdraw contract balance in admin account
    function withdraw() external onlyAdmin{
        payable(admin).transfer(address(this).balance);  
        emit Withdrawal(address(this).balance);
    }
}



