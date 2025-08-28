import React, { useState } from 'react';
import {
  Card, CardContent, IconButton, TextField, Typography
} from '@mui/material';
import { Edit, Delete } from '@mui/icons-material';
import axios from 'axios';
import { supabase } from '../services/supabase'; // Make sure this path is correct
import { v4 as uuidv4 } from 'uuid';

const CategoryCard = ({ category, onUpdate, onDelete }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState(category.categoryname);
  const [desc, setDesc] = useState(category.description);
  const [newFile, setNewFile] = useState(null);
  const [imageurl, setImageurl] = useState(category.imageurl);

  const handleSave = async () => {
    try {
      let finalImageUrl = imageurl;

      // Upload to Supabase if new file is selected
      if (newFile) {
        const fileExt = newFile.name.split('.').pop();
        const fileName = `${uuidv4()}.${fileExt}`;
        const filePath = `categories/${fileName}`;

        const { error: uploadError } = await supabase.storage
          .from('category-images') 
          .upload(filePath, newFile, {
            cacheControl: '3600',
            upsert: true,
          });

        if (uploadError) {
          throw new Error('Upload failed: ' + uploadError.message);
        }

        const { data } = supabase.storage
          .from('category-images')
          .getPublicUrl(filePath);

        finalImageUrl = data.publicUrl;
      }

      await axios.put(`http://localhost:8080/api/categories/${category.categoryid}`, {
        categoryname: name,
        description: desc,
        imageurl: finalImageUrl,
      });

      setImageurl(finalImageUrl);
      setIsEditing(false);
      setNewFile(null);
      onUpdate();
    } catch (err) {
      console.error('Update failed:', err.message);
      alert('Update failed');
    }
  };

  

  return (
    <Card className="flex flex-col sm:flex-row items-start sm:items-center justify-between px-4 py-3 gap-4">
      {imageurl && (
        <img
          src={imageurl}
          alt={category.categoryname}
          className="w-24 h-24 object-cover rounded"
        />
      )}

      <CardContent className="flex-grow w-full">
        {isEditing ? (
          <div className="flex flex-col gap-2">
            <TextField
              label="Name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              fullWidth
            />
            <TextField
              label="Description"
              value={desc}
              onChange={(e) => setDesc(e.target.value)}
              fullWidth
              multiline
            />
            <input
              type="file"
              accept="image/*"
              onChange={(e) => setNewFile(e.target.files[0])}
            />
            <button
              onClick={handleSave}
              className="bg-blue-600 text-white px-3 py-1 rounded mt-2"
            >
              Save
            </button>
          </div>
        ) : (
          <>
            <Typography variant="h6">{category.categoryname}</Typography>
            <Typography variant="body2" color="textSecondary">
              {category.description}
            </Typography>
          </>
        )}
      </CardContent>

      {!isEditing && (
        <div className="flex flex-row sm:flex-col">
          <IconButton onClick={() => setIsEditing(true)} color="primary">
            <Edit />
          </IconButton>
          
        </div>
      )}
    </Card>
  );
};

export default CategoryCard;
