import React, { useState } from 'react';
import {
  Modal, Box, TextField, Button, Typography
} from '@mui/material';
import { v4 as uuidv4 } from 'uuid';
import axios from 'axios';
import { supabase } from '../services/supabase'; 

const style = {
  position: 'absolute',
  top: '50%', left: '50%',
  transform: 'translate(-50%, -50%)',
  width: 400,
  bgcolor: 'background.paper',
  boxShadow: 24,
  p: 4,
  borderRadius: 2
};

const AddCategoryModal = ({ open, onClose, onCategoryAdded }) => {
  const [categoryname, setCategoryname] = useState('');
  const [description, setDescription] = useState('');
  const [file, setFile] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    if (!categoryname || !description || !file) {
      alert('Please fill all fields.');
      return;
    }

    try {
      setLoading(true);

      const fileExt = file.name.split('.').pop();
      const fileName = `${uuidv4()}.${fileExt}`;
      const filePath = `saviya/categories/${fileName}`;

      // Upload to Supabase Storage
      const { error: uploadError } = await supabase.storage
        .from('category-images')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: true,
        });

      if (uploadError) throw uploadError;

      // Get public URL
      const { data } = supabase
        .storage
        .from('category-images')
        .getPublicUrl(filePath);

      const imageurl = data.publicUrl;

      // Send to your backend
      await axios.post('http://localhost:8080/api/categories/create', {
        categoryname,
        description,
        imageurl
      });

      onCategoryAdded();
      onClose();
      setCategoryname('');
      setDescription('');
      setFile(null);
    } catch (error) {
      console.error('Error adding category:', error.message);
      alert('Failed to add category');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal open={open} onClose={onClose}>
      <Box sx={style}>
        <Typography variant="h6" gutterBottom>Add Category</Typography>
        <TextField
          fullWidth
          label="Category Name"
          value={categoryname}
          onChange={(e) => setCategoryname(e.target.value)}
          margin="normal"
        />
        <TextField
          fullWidth
          label="Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          margin="normal"
        />
        <input
          type="file"
          accept="image/*"
          onChange={(e) => setFile(e.target.files[0])}
          style={{ marginTop: '1rem', marginBottom: '1rem' }}
        />
        <Button
          variant="contained"
          color="primary"
          fullWidth
          onClick={handleSubmit}
          disabled={loading}
        >
          {loading ? 'Uploading...' : 'Submit'}
        </Button>
      </Box>
    </Modal>
  );
};

export default AddCategoryModal;
