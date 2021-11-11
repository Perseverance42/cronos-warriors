pragma solidity ^0.8.0;

library VisualsLib {
    
    uint256 constant maxNameBytesLenght = 64;
    
    struct Visuals {
        string name;
        uint256 dna; 
    }
    
    function isNull(Visuals memory visuals) public pure returns (bool){
        return !isValidName(visuals.name); //might get better check with more attibutes in Visuals
    }
    
    function isValidName(string memory name) public pure returns (bool){
        uint256 l = bytes(name).length;
        return l > 0 && l <= maxNameBytesLenght;
    }

    function randomDNA(string memory name, uint256 offset) public view returns (uint256){
        uint256 rand = uint256(keccak256(abi.encodePacked(
            ((uint256(keccak256(abi.encodePacked(tx.origin)))) / (3))
            +((uint256(keccak256(abi.encodePacked(name)))) / (3))
            + offset)));
        return uint256(rand);
    }
}